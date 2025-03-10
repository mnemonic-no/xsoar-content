import demistomock as demisto  # noqa: F401
from CommonServerPython import *  # noqa: F401

""" IMPORTS """

import json
import urllib.parse


""" CONSTANTS """
LOG_LINE = "UrlqueryDebugLog: "  # Make sure to use a line easily to search and read in logs.
DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"


""" CLIENT CLASS """


class Client(BaseClient):

    def list_reports(self, limit=10):
        uri = "/public/v1/recent/reports/"

        params = {"limit": limit}

        response = self._http_request(method="GET", url_suffix=uri, params=params)

        return response

    def get_report(self, report_id):
        uri = f"/public/v1/report/{report_id}"

        response = self._http_request(method="GET", url_suffix=uri)

        return response

    def get_report_screenshot(self, report_id):
        uri = f"/public/v1/report/{report_id}/screenshot"

        response = self._http_request(method="GET", url_suffix=uri, resp_type="content")

        return response

    def get_report_domain_graph(self, report_id):
        uri = f"/public/v1/report/{report_id}/domain_graph"

        response = self._http_request(method="GET", url_suffix=uri, resp_type="content")

        return response

    def submit_url(self, args):
        uri = "/public/v1/submit/url"

        url = args.get("url")
        ua = args.get("ua", "Mozilla/5.0 (X11; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0")

        referer = args.get("referer", "")
        access = args.get("access", "public")

        data = {"url": url, "useragent": ua, "referer": referer, "access": access}

        data = json.dumps(data)

        return self._http_request(method="POST", url_suffix=uri, data=data)

    def queue_status(self, queue_id):
        uri = f"/public/v1/submit/status/{queue_id}"

        return self._http_request(method="GET", url_suffix=uri)

    def search_url(self, args):
        uri = "/public/v1/search/reports/"

        url = args.get("url")
        limit = args.get("limit", 10)
        offset = args.get("offset", 0)

        encoded_url = urllib.parse.quote(url, safe=":/?&=")

        params = {"query": encoded_url, "limit": limit, "offset": offset}

        return self._http_request(method="GET", url_suffix=uri, params=params)

    def check_reputation(self, url):
        uri = "/public/v1/reputation/check/"

        encoded_url = urllib.parse.quote(url, safe=":/?&=")

        params = {
            "query": encoded_url,
        }

        return self._http_request(method="GET", url_suffix=uri, params=params)


""" HELPER FUNCTIONS """


""" COMMAND FUNCTIONS """


def test_module(client: Client) -> str:
    try:
        client.list_reports(limit=1)

    except DemistoException as e:
        if "Forbidden" in str(e):
            return "Authorization Error: make sure API Key is correctly set"
        else:
            raise e

    return "ok"


def urlquery_get_report_command(client, args):
    response = client.get_report(report_id=args.get("report_id", ""))

    meta_dict = {
        "Address": response["url"]["addr"],
        "Full report (external link)": "https://urlquery.net/report/" + response["report_id"],
        "Analyzer alerts": response["stats"]["alert_count"]["analyzer"],
        "Date": response["date"],
        "IDS alerts": response["stats"]["alert_count"]["ids"],
        "Urlquery alerts": response["stats"]["alert_count"]["urlquery"],
        "IP": response["ip"]["addr"],
        "IP Info": "AS: {} - ASN: {} - Country: {}".format(
            response["ip"]["as"], response["ip"]["asn"], response["ip"]["country"]
        ),
    }

    hr = tableToMarkdown(
        "Urlquery results for {}".format(response["url"]["addr"]),
        meta_dict,
        headers=[
            "Address",
            "Date",
            "Analyzer alerts",
            "IDS alerts",
            "Urlquery alerts",
            "IP",
            "IP Info",
            "Full report (external link)",
        ],
    )

    if args.get("include_requests", "false").lower() == "true":
        http_list = []

        for http in response["http"]:
            http_dict = {
                "Domain": http["url"]["fqdn"],
                "IP": http["ip"]["addr"],
                "URL": http["request"]["method"] + " - " + http["url"]["addr"],
                "Status code": http["response"]["status_code"] + " ({})".format(http["response"]["status_text"]),
            }

            alerts = 0
            if http["alerts"]["analyzer"]:
                alerts += len(http["alerts"]["analyzer"])
            if http["alerts"]["ids"]:
                alerts += len(http["alerts"]["ids"])
            if http["alerts"]["urlquery"]:
                alerts += len(http["alerts"]["urlquery"])

            http_dict["Alerts"] = alerts

            http_list.append(http_dict)

        hr_http = tableToMarkdown(
            "HTTP(S) requests", http_list, headers=["Domain", "IP", "URL", "Status code", "Alerts"]
        )

        hr += hr_http

    if args.get("include_artifacts", "false").lower() == "true":
        if "artifacts" in response.keys():
            if "files" in response["artifacts"].keys():
                if response["artifacts"]["files"]:
                    if len(response["artifacts"]["files"]) > 0:
                        files = []

                        for file in response["artifacts"]["files"]:
                            file_dict = {
                                "sha1": file["sha1"],
                                "IP": file["ip"]["addr"],
                                "Country": file["ip"]["country_code"],
                                "File magic": file["magic"],
                                "File url": file["url"]["addr"],
                            }
                            if "alerts" in file.keys():
                                if "analyzer" in file["alerts"].keys():
                                    file_dict["File alerts"] = len(file["alerts"]["analyzer"])
                                    file_dict["File alert details"] = file["alerts"]["analyzer"]
                            files.append(file_dict)

                        hr_files = tableToMarkdown("File artifacts", files)
                        hr += hr_files

    return CommandResults(
        readable_output=hr, outputs_prefix="Urlquery.Report", outputs_key_field="report_id", outputs=response
    )


def urlquery_get_report_screenshot_command(client, args):
    response = client.get_report_screenshot(report_id=args.get("report_id", ""))

    file_result = fileResult(
        "urlquery_{}.png".format(args.get("report_id", "")), response, file_type=EntryType.ENTRY_INFO_FILE
    )
    file_result["Type"] = entryTypes["image"]

    return file_result


def urlquery_get_report_domain_graph_command(client, args):
    response = client.get_report_domain_graph(reportid=args.get("report_id", ""))

    file_result = fileResult(
        "urlquery_domain_graph_{}.png".format(args.get("report_id", "")), response, file_type=EntryType.ENTRY_INFO_FILE
    )
    file_result["Type"] = entryTypes["image"]

    return file_result


def urlquery_submit_url_command(client, args):
    response = client.submit_url(args)

    hr_dict = {
        "Status": response["status"],
        "Report id": response["report_id"],
        "Queue id": response["queue_id"],
        "User Agent": response["useragent"],
        "Referer": response["referer"],
        "Access": response["access"],
        "Full report (external link)": "https://urlquery.net/report/" + response["report_id"],
    }

    hr = tableToMarkdown(
        "Urlquery submit status for {}".format(args.get("url")),
        hr_dict,
        headers=["Status", "Report id", "Queue id", "User Agent", "Referer", "Access", "Full report (external link)"],
    )

    return CommandResults(
        readable_output=hr, outputs_prefix="Urlquery.Submit", outputs_key_field="report_id", outputs=response
    )


def urlquery_submit_status_command(client, args):
    response = client.queue_status(args.get("queue_id"))

    status = "Running"
    if response["status"] == "done":
        status = "Done"

    return CommandResults(
        readable_output=status, outputs_prefix="Urlquery.Submit", outputs_key_field="report_id", outputs=response
    )


def urlquery_search_command(client, args):
    response = client.search_url(args)

    if response["total_hits"] > 0:
        meta = []

        for report in response["reports"]:
            meta_dict = {
                "Address": report["url"]["addr"],
                "Report ID": report["report_id"],
                "Full report (external link)": "https://urlquery.net/report/" + report["report_id"],
                "Analyzer alerts": report["stats"]["alert_count"]["analyzer"],
                "Date": report["date"],
                "IDS alerts": report["stats"]["alert_count"]["ids"],
                "Urlquery alerts": report["stats"]["alert_count"]["urlquery"],
                "IP": report["ip"]["addr"],
                "IP Info": "AS: {} - ASN: {} - Country: {}".format(
                    report["ip"]["as"], report["ip"]["asn"], report["ip"]["country"]
                ),
            }
            meta.append(meta_dict)

        hr = tableToMarkdown(
            "Urlquery search results for {} ({} hits)".format(args.get("url"), response["total_hits"]),
            meta,
            headers=[
                "Address",
                "Date",
                "Report ID",
                "Analyzer alerts",
                "IDS alerts",
                "Urlquery alerts",
                "IP",
                "IP Info",
                "Full report (external link)",
            ],
        )

        return CommandResults(
            readable_output=hr, outputs_prefix="Urlquery.Search", outputs_key_field="", outputs=response
        )

    return CommandResults(readable_output=f"No search results for {args.get('url')}")


def url_command(client, args):
    url = args.get("url")
    response = client.check_reputation(url)
    SCORES = {0: "Unknown", 1: "Good", 2: "Suspicious", 3: "Malicious"}
    verdict = response["verdict"]

    score = Common.DBotScore.NONE
    num_verdict = 0
    if verdict.lower() == "suspicious":
        score = Common.DBotScore.SUSPICIOUS
        num_verdict = 2
    if verdict.lower() == "malware" or verdict.lower() == "malicious":
        score = Common.DBotScore.BAD
        num_verdict = 3

    url_raw_response = {"Data": url, SCORES[num_verdict]: {"Vendor": "urlquery.net", "Description": "urlquery.net"}}

    dbot_score = Common.DBotScore(
        indicator=url,
        indicator_type=DBotScoreType.URL,
        integration_name="Urlquery",
        reliability="C - Fairly reliable",  # todo - configurable in integration settings
        score=score,
    )

    url_entry = Common.URL(url=url, dbot_score=dbot_score)

    hr = tableToMarkdown("Domain reputation from urlquery.net for {}".format(url), url_raw_response)

    return CommandResults(
        outputs_prefix="URL",
        outputs_key_field="Data",
        outputs=url_raw_response,
        readable_output=hr,
        indicator=url_entry,
    )


""" MAIN FUNCTION """


def main() -> None:  # pragma: no cover
    params = demisto.params()
    args = demisto.args()
    command = demisto.command()

    api_key = params.get("credentials", {}).get("password", None)

    base_url = params.get("url")

    verify_certificate = not params.get("insecure", False)

    proxy = params.get("proxy", False)

    try:
        headers = {
            "accept": "application/json",
            "x-apikey": api_key,
        }

        client = Client(base_url=base_url, verify=verify_certificate, headers=headers, proxy=proxy)

        if command == "test-module":
            result = test_module(client)

            return_results(result)

        elif command == "urlquery-get-report":
            if args.get("include_screenshot", "false").lower() == "true":
                return_results(urlquery_get_report_screenshot_command(client, args))

            if args.get("include_domain_graph", "false").lower() == "true":
                return_results(urlquery_get_report_domain_graph_command(client, args))

            return_results(urlquery_get_report_command(client, args))

        elif command == "urlquery-get-report-screenshot":
            return_results(urlquery_get_report_screenshot_command(client, args))

        elif command == "urlquery-get-report-domain-graph":
            return_results(urlquery_get_report_domain_graph_command(client, args))

        elif command == "urlquery-submit-url":
            return_results(urlquery_submit_url_command(client, args))

        elif command == "urlquery-submit-status":
            return_results(urlquery_submit_status_command(client, args))
        elif command == "urlquery-search":
            return_results(urlquery_search_command(client, args))

        elif command == "url":
            return_results(url_command(client, args))

    except Exception as e:
        return_error(f"Failed to execute {command} command.\nError:\n{str(e)}")


""" ENTRY POINT """

if __name__ in ("__main__", "__builtin__", "builtins"):
    main()

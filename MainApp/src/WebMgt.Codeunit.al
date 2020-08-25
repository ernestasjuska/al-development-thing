codeunit 50102 "ALDT Web Mgt."
{
    Access = Internal;

    internal procedure FormBasicAuthorizationHeader(User: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit('Basic ' + Base64Convert.ToBase64(User + ':' + Password));
    end;

    internal procedure GetTenantWebServiceUrl(ObjectType: Enum "ALDT Tenant WS Object Type"; WebServiceName: Text; ClientType: Enum "Client Type"): Text
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        case ObjectType of
            ObjectType::Page:
                TenantWebService.Get(TenantWebService."Object Type"::Page, WebServiceName);
            ObjectType::Codeunit:
                TenantWebService.Get(TenantWebService."Object Type"::Codeunit, WebServiceName);
            ObjectType::Query:
                TenantWebService.Get(TenantWebService."Object Type"::Query, WebServiceName);
        end;
        WebServiceAggregate.TransferFields(TenantWebService, true);
        exit(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType));
    end;

    internal procedure GetODataV4(Url: Text; AuthorizationHeader: Text) PageObject: JsonObject
    var
        HttpRequestHeaders: Dictionary of [Text, Text];
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin
        if AuthorizationHeader <> '' then
            HttpRequestHeaders.Add('Authorization', AuthorizationHeader);

        Get(Url, HttpRequestHeaders, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseText);
        PageObject.ReadFrom(ResponseText);
    end;

    local procedure Get(Url: Text; HttpHeaders: Dictionary of [Text, Text]; var HttpResponseMessage: HttpResponseMessage)
    var
        HttpClient: HttpClient;
        HeaderName: Text;
        HeaderValue: Text;
        ResponseText: Text;
        FailedRequestErr: Label 'Failed request (GET %1) with code %2, reason phrase: %3\\%4', Comment = '%1 = url; %2 = http status code; %3 = reason phrase; %4 = response text';
    begin
        foreach HeaderName in HttpHeaders.Keys() do begin
            HttpHeaders.Get(HeaderName, HeaderValue);
            HttpClient.DefaultRequestHeaders().Add(HeaderName, HeaderValue);
        end;

        HttpClient.Get(Url, HttpResponseMessage);

        if not HttpResponseMessage.Content().ReadAs(ResponseText) then
            ResponseText := '';

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(FailedRequestErr, Url, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase(), ResponseText);
    end;
}
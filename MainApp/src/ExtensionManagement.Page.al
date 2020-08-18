page 50100 "ALDT Extension Management"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = List;
    Editable = false;
    SourceTable = "ALDT Extension Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                }
                field(Version; Format(Version.Create(Rec."Version Major", Rec."Version Minor", Rec."Version Build", Rec."Version Revision")))
                {
                    ApplicationArea = All;
                }
                field(Installed; Rec.Installed)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
        Base64Convert: Codeunit "Base64 Convert";
        WebServiceManagement: Codeunit "Web Service Management";
        E: Codeunit "Extension Management";
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        ResponseContent: HttpContent;
        ResponseText: Text;
        Url: Text;
        ODataPageJson: JsonObject;
        ODataValueJson: JsonToken;
        ODataItemJson: JsonToken;
        ODataPropertyJson: JsonToken;
        PackageVersion: Version;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        HttpClient.DefaultRequestHeaders().Add('Authorization', 'Basic ' + Base64Convert.ToBase64('demo:Password123.'));

        TenantWebService.Get(TenantWebService."Object Type"::Page, 'ALDTExtensionManagement');
        WebServiceAggregate.TransferFields(TenantWebService, true);

        Url := WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, "Client Type"::ODataV4);

        HttpClient.Get(Url, Response);

        ResponseContent := Response.Content();
        if not ResponseContent.ReadAs(ResponseText) then
            ResponseText := '';

        if not Response.IsSuccessStatusCode() then
            Error('Failed request with code %1, reason phrase: %2\\%3', Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseText);

        //Message('Succeeded request with code %1, reason phrase: %2\\%3', Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseText);


        ODataPageJson.ReadFrom(ResponseText);
        ODataPageJson.Get('value', ODataValueJson);
        foreach ODataItemJson in ODataValueJson.AsArray() do begin
            Rec.Init();

            ODataItemJson.AsObject().Get('Runtime_Package_ID', ODataPropertyJson);
            Rec."Package ID" := ODataPropertyJson.AsValue().AsText();

            ODataItemJson.AsObject().Get('Name', ODataPropertyJson);
            Rec.Name := CopyStr(ODataPropertyJson.AsValue().AsText(), 1, MaxStrLen(Rec.Name));

            ODataItemJson.AsObject().Get('Version', ODataPropertyJson);
            PackageVersion := Version.Create(ODataPropertyJson.AsValue().AsText().Replace('v. ', ''));
            Rec."Version Major" := PackageVersion.Major;
            Rec."Version Minor" := PackageVersion.Minor;
            Rec."Version Build" := PackageVersion.Build;
            Rec."Version Revision" := PackageVersion.Revision;

            ODataItemJson.AsObject().Get('AdditionalInfo', ODataPropertyJson);
            Rec.Installed := ODataPropertyJson.AsValue().AsText() = 'Installed';

            Rec.Insert();
        end;
    end;
}
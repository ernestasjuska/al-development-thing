codeunit 50100 "ALDT Extension Mgt."
{
    Access = Internal;

    var
        WebMgt: Codeunit "ALDT Web Mgt.";
        JSONHelper: Codeunit "ALDT JSON Helper";

    internal procedure GetPublishedExtensions(var TempExtensionBuffer: Record "ALDT Extension Buffer" temporary)
    var
        TempExtensionBuffer2: Record "ALDT Extension Buffer" temporary;
        ODataPageJson: JsonObject;
        ODataValueJson: JsonToken;
        ODataItemJson: JsonToken;
    begin
        TempExtensionBuffer2.Copy(TempExtensionBuffer, true);
        TempExtensionBuffer2.Reset();
        TempExtensionBuffer2.DeleteAll();

        ODataPageJson := WebMgt.GetODataV4(GetTenantExtensionsPageODataV2EndpointUrl(), GetTenantWebServiceAuthorizationHeader());

        ODataPageJson.Get('value', ODataValueJson);
        foreach ODataItemJson in ODataValueJson.AsArray() do begin
            TempExtensionBuffer2.Init();

            TempExtensionBuffer2."Package ID" := JSONHelper.GetText(ODataItemJson, 'packageId');
            TempExtensionBuffer2."App ID" := JSONHelper.GetText(ODataItemJson, 'id');
            TempExtensionBuffer2.Name := CopyStr(JSONHelper.GetText(ODataItemJson, 'displayName'), 1, MaxStrLen(TempExtensionBuffer2.Name));
            TempExtensionBuffer2.Publisher := CopyStr(JSONHelper.GetText(ODataItemJson, 'publisher'), 1, MaxStrLen(TempExtensionBuffer2.Publisher));
            TempExtensionBuffer2."Version Major" := JSONHelper.GetInteger(ODataItemJson, 'versionMajor');
            TempExtensionBuffer2."Version Minor" := JSONHelper.GetInteger(ODataItemJson, 'versionMinor');
            TempExtensionBuffer2."Version Build" := JSONHelper.GetInteger(ODataItemJson, 'versionBuild');
            TempExtensionBuffer2."Version Revision" := JSONHelper.GetInteger(ODataItemJson, 'versionRevision');
            TempExtensionBuffer2.Installed := JSONHelper.GetBoolean(ODataItemJson, 'isInstalled');

            // NOTE: other properties are "scope" (integer - 0:global, 1: dev), "publishedAs" (string - "Global" | " Dev" - not a typo -_-)

            TempExtensionBuffer2.Insert();
        end;
    end;

    internal procedure GetTenantWebServiceAuthorizationHeader(): Text
    begin
        exit(WebMgt.FormBasicAuthorizationHeader('admin', '5n0+B5cuDH9rIpJAF1vBis6FtueOukKSu5oPthY576E='));
    end;

    internal procedure GetTenantExtensionsPageODataV2EndpointUrl(): Text
    begin
        exit(WebMgt.GetTenantWebServiceUrl("ALDT Tenant WS Object Type"::Page, 'ALDTTenantExtensions', "Client Type"::ODataV4));
    end;
}
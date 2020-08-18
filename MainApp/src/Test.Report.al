report 50100 "ALDT Test"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    trigger OnPostReport()
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        Uri: Codeunit Uri;
        HttpClient: HttpClient;
        RequestContent: HttpContent;
        HttpHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        ResponseContent: HttpContent;
        ClientFileName: Text;
        PackageStream: InStream;
        RequestContentWriter: OutStream;
        RequestContentReader: InStream;
        ResponseText: Text;
        NewLine: Text[2];
        Boundary: Text;
    begin
        NewLine[1] := 13;
        NewLine[2] := 10;
        Boundary := '27d43a0d-6034-4d66-b5c5-f4687f486bfd';

        UploadIntoStream('Upload package', '', 'AL package files (*.app)|*.app', ClientFileName, PackageStream);

        HttpClient.DefaultRequestHeaders().Add('Authorization', 'Basic ' + Base64Convert.ToBase64('demo:Password123.'));

        RequestContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'multipart/form-data;boundary="' + Boundary + '"');

        Clear(TempBlob);
        TempBlob.CreateOutStream(RequestContentWriter);
        RequestContentWriter.WriteText(
            '--' + Boundary + NewLine +
            'Content-Disposition: form-data; name="=?utf-8?B?RXJuZXN0YXMgSnXFoWthX0FMIERldmVsb3BtZW50IFRoaW5nXzEuMC4wLjAuYXBw?="; filename="=?utf-8?B?RXJuZXN0YXMgSnXFoWthX0FMIERldmVsb3BtZW50IFRoaW5nXzEuMC4wLjAuYXBw?="; filename*=utf-8''''' + Uri.EscapeDataString(ClientFileName) + NewLine +
            NewLine);
        CopyStream(RequestContentWriter, PackageStream);
        RequestContentWriter.WriteText(
            NewLine +
            '--' + Boundary + '--' + NewLine);

        TempBlob.CreateInStream(RequestContentReader);
        RequestContent.WriteFrom(RequestContentReader);

        HttpClient.Post('http://localhost:7049/bc/dev/apps?tenant=default&SchemaUpdateMode=synchronize&DependencyPublishingOption=default', RequestContent, Response);

        ResponseContent := Response.Content();
        if not ResponseContent.ReadAs(ResponseText) then
            ResponseText := '';

        if not Response.IsSuccessStatusCode() then
            Error('Failed request with code %1, reason phrase: %2\\%3', Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseText);

        Message('Succeeded request with code %1, reason phrase: %2\\%3', Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseText);
    end;
}
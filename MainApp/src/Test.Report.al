report 50100 "ALDT Test"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    trigger OnPostReport()
    var
        Base64Convert: Codeunit "Base64 Convert";
        HttpClient: HttpClient;
        RequestContent: HttpContent;
        HttpHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        ResponseContent: HttpContent;
        ClientFileName: Text;
        PackageStream: InStream;
        ResponseText: Text;
        NewLine: Text[2];
        Boundary: Text;
    begin
        NewLine[1] := 13;
        NewLine[2] := 10;
        Boundary := '27d43a0d-6034-4d66-b5c5-f4687f486bfd';

        //AL package files (*.app)|*.app|All files (*.*)|*.*
        UploadIntoStream('Upload package', '', '', ClientFileName, PackageStream);

        HttpClient.SetBaseAddress('http://localhost:7049/bc');
        HttpClient.DefaultRequestHeaders().Add('Authorization', 'Basic ' + Base64Convert.ToBase64('demo:Password123.'));

        RequestContent.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Content-Type', 'multipart/form-data;boundary="' + Boundary + '"');

        RequestContent.WriteFrom('--' + Boundary + NewLine);
        RequestContent.WriteFrom('Content-Disposition: form-data; name="Package"; filename="' + ClientFileName + '"' + NewLine);
        RequestContent.WriteFrom(NewLine);
        RequestContent.WriteFrom(PackageStream);
        RequestContent.WriteFrom(NewLine);
        RequestContent.WriteFrom('--' + Boundary + '--');

        HttpClient.Post('dev/apps?tenant=default', RequestContent, Response);

        ResponseContent := Response.Content();
        RequestContent.ReadAs(ResponseText);

        if not Response.IsSuccessStatusCode() then
            Error('Failed request with code %1, reason phrase: %2\\%3', Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseText);

        Message('Succeeded request with code %1, reason phrase: %2\\%4', Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseText);
    end;
}
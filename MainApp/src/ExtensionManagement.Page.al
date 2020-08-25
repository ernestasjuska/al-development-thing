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
        ExtensionMgt: Codeunit "ALDT Extension Mgt.";
    begin
        ExtensionMgt.GetPublishedExtensions(Rec);
    end;
}
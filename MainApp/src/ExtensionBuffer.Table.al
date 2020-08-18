table 50100 "ALDT Extension Buffer"
{
    fields
    {
        field(1; "Package ID"; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(2; "App ID"; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(4; Publisher; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Version Major"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Version Minor"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Version Build"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Version Revision"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(9; Installed; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Package ID")
        {
            Clustered = true;
        }
    }
}
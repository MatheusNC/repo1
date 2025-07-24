table 51001 "PTR Extension Schedule"
{
    Caption = 'Extension Schedule';

    fields
    {
        field(1; "File Name"; Text[100])
        {
            Caption = 'File Name';
        }
        field(2; "Schedule Date"; Date)
        {
            Caption = 'Schedule Date';
        }
        field(3; Priority; Integer)
        {
            Caption = 'Priority';
            InitValue = 1;
            MinValue = 1;
            MaxValue = 10;
        }
        field(4; "App File"; Blob)
        {
            Caption = 'App File';
        }
        field(5; "Extension Status"; Enum "PTR Schedule Extension Status")
        {
            Caption = 'Extension Status';
        }
        field(6; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language.Code;
        }
        field(7; "App Id"; Guid)
        {
            Caption = 'App Id';
            NotBlank = true;
        }
        field(8; "Schedule Time"; Time)
        {
            Caption = 'Schedule Time';
        }
        field(9; "Sync Mode"; Enum "Extension Sync Mode")
        {
            Caption = 'Sync Mode';
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(11; "Package Id"; Guid)
        {
            Caption = 'Package Id';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "App Id", Priority, "Line No.") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Priority, "File Name", "Language Code") { }
    }

    trigger OnInsert()
    begin
        if "Language Code" = '' then
            "Language Code" := Language.GetLanguageCode(GlobalLanguage());

        "Line No." := GetLastLineNo() + 10000;
    end;

    trigger OnModify()
    begin
        if "Extension Status" = "Extension Status"::Completed then
            TestField("Extension Status", "Extension Status"::"Not Initialized");
    end;

    trigger OnDelete()
    begin
        DeleteRelations();
    end;

    var
        Language: Codeunit Language;

    procedure GetLastLineNo(): Integer
    var
        ExtensionSchedule: Record "PTR Extension Schedule";
    begin
        if ExtensionSchedule.FindLast() then
            exit(ExtensionSchedule."Line No.");
    end;

    local procedure DeleteRelations()
    var
        ExtnScheduleDependency: Record "PTR Extn. Schedule Dependency";
    begin
        ExtnScheduleDependency.SetRange("App Id", "App Id");
        ExtnScheduleDependency.DeleteAll();
    end;
}

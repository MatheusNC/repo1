page 51003 "PTR Extension Schedule List"
{
    ApplicationArea = All;
    Caption = 'Extensions Schedule List';
    PageType = List;
    SourceTable = "PTR Extension Schedule";
    SourceTableView = sorting("App Id", Priority, "Line No.") order(descending);
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the value of the Priority field.';
                }
                field("App Id"; Rec."App Id")
                {
                    ToolTip = 'Specifies the value of the App Id field.';
                }
                field("File Name"; Rec."File Name")
                {
                    ToolTip = 'Specifies the value of the File Name field.';
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ToolTip = 'Specifies the value of the Schedule Date field.';
                }
                field("Schedule Time"; Rec."Schedule Time")
                {
                    ToolTip = 'Specifies the value of the Schedule Time field.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ToolTip = 'Specifies the value of the Language Code field.';
                }
                field("Sync Mode"; Rec."Sync Mode")
                {
                    ToolTip = 'Specifies how the extension will be synchronized.';
                }
                field("Extension Status"; Rec."Extension Status")
                {
                    ToolTip = 'Specifies the value of the Extension Status field.';
                }
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        Rec."Extension Status" := ScheduleExtensionMgt.GetExtensionStatus(Rec);
        Rec.Modify();
    end;

    var
        ScheduleExtensionMgt: Codeunit "PTR Schedule Extension Mgt.";
}
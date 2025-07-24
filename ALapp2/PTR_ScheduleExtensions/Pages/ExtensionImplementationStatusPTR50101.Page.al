page 51001 "PTR Extn. Impl. Status"
{
    Caption = 'Implementation Status';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Extension Deployment Status";
    SourceTableTemporary = true;
    SourceTableView = order(descending);
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Started On"; Rec."Started On")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Details; DetailsTxt)
                {
                    Caption = 'Details';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refresh the list';

                trigger OnAction()
                begin
                    Rec.DeleteAll();
                    ExtensionManagement.GetAllExtensionDeploymentStatusEntries(Rec);
                    Rec.SetCurrentKey("Started On");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ExtensionManagement.GetAllExtensionDeploymentStatusEntries(Rec);
        Rec.SetCurrentKey("Started On");
        Rec.SetAscending("Started On", false);
        Rec.FindFirst();
    end;

    trigger OnAfterGetRecord()
    begin
        DetailsTxt := ExtensionManagement.GetDeploymentDetailedStatusMessage(Rec."Operation ID");
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";
        InS: InStream;
        DetailsTxt: Text;
}
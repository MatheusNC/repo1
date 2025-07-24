page 51000 "PTR Extensions Schedule"
{
    ApplicationArea = All;
    Caption = 'Extensions Schedule';
    PageType = List;
    SourceTable = "PTR Extension Schedule";
    SourceTableView = sorting("App Id", Priority, "Line No.") order(descending);
    UsageCategory = Lists;

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
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        InS: InStream;
                        OutS: OutStream;
                    begin
                        if Rec."Extension Status" <> Rec."Extension Status"::"Not Initialized" then
                            Error(StatusNotInitializedErr);

                        if Rec."App File".HasValue() then
                            if not Confirm('The file will be replaced. Do you want to continue?') then
                                exit;

                        UploadIntoStream('Select the file to upload', '', '', Rec."File Name", InS);
                        Rec."App File".CreateOutStream(OutS);
                        CopyStream(OutS, InS);
                        Rec.Modify();
                    end;
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
                    Editable = false;
                }
            }
            part(ExtnImplementationStatus; "PTR Extn. Impl. Status")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadExtension)
            {
                Caption = 'Upload Extension';
                Image = Import;
                ToolTip = 'Upload the extension file.';

                trigger OnAction()
                var
                    ExtnScheduleDependency: Record "PTR Extn. Schedule Dependency";
                    InS: InStream;
                    LanguageId: Integer;
                begin
                    if not Rec."App File".HasValue() then
                        Error(FileUploadErr);

                    if Rec."Extension Status" = Rec."Extension Status"::Completed then
                        Error(StatusCompletedErr);

                    ExtnScheduleDependency.SetRange("App Id", Rec."App Id");
                    if ExtnScheduleDependency.FindSet() then
                        repeat
                            if not ExtensionManagement.IsInstalledByAppId(ExtnScheduleDependency."Dependency App Id") then
                                Error(ExtensionHasDependenciesErr);
                        until ExtnScheduleDependency.Next() = 0;

                    Rec.CalcFields("App File");
                    Rec."App File".CreateInStream(InS);
                    ScheduleExtensionMgt.UploadExtension(InS, Language.GetLanguageId(Rec."Language Code"), Rec."Sync Mode");

                    Rec."Extension Status" := Rec."Extension Status"::Initialized;
                    Rec.Modify();

                    if Confirm(ConfirmUploadLbl) then begin
                        Commit();
                        Page.RunModal(Page::"Extension Deployment Status");
                    end;
                end;
            }
            action(SetToNotInitialized)
            {
                Caption = 'Set to Not Initialized';
                Image = Status;
                ToolTip = 'Set the status of the extension to Not Initialized.';

                trigger OnAction()
                begin
                    if Rec."Extension Status" = Rec."Extension Status"::Completed then
                        Error(StatusNotInitializedErr);

                    Rec."Extension Status" := Rec."Extension Status"::"Not Initialized";
                    Rec.Modify();
                end;
            }
            action(SetToOnHold)
            {
                Caption = 'Set to On Hold';
                Image = Status;
                ToolTip = 'Set the status of the extension to On Hold.';

                trigger OnAction()
                begin
                    if Rec."Extension Status" = Rec."Extension Status"::Completed then
                        Error(StatusNotInitializedErr);

                    Rec."Extension Status" := Rec."Extension Status"::"On Hold";
                    Rec.Modify();
                end;
            }
        }
        area(Navigation)
        {
            action(Dependencies)
            {
                Caption = 'Dependencies';
                Image = CheckList;
                ToolTip = 'View the dependencies of the extension.';
                RunObject = page "PTR Extn. Sched. Dependencies";
                RunPageLink = "App Id" = field("App Id");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                ShowAs = SplitButton;
                actionref(UploadExtension_Promoted; UploadExtension) { }
                actionref(SetToNotInitialized_Promoted; SetToNotInitialized) { }
                actionref(SetToOnHold_Promoted; SetToOnHold) { }
                actionref(Dependencies_Promoted; Dependencies) { }
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
        ExtensionManagement: Codeunit "Extension Management";
        Language: Codeunit Language;
        FileUploadErr: Label 'The file does not exist.';
        ConfirmUploadLbl: Label 'The extension file has been uploaded successfully. Do you want to see the implmentation status?';
        StatusNotInitializedErr: Label 'The action cannot be performed because the extension status is not "Not Initialized".';
        StatusCompletedErr: Label 'The status cannot be changed because the extension has been implemented.';
        ExtensionHasDependenciesErr: Label 'The extension has dependencies that are not installed.';
}
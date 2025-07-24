codeunit 51001 "PTR Schedule Extension Mgt."
{
    Permissions = tabledata "NAV App Installed App" = R;
    trigger OnRun()
    begin
        UploadExtensions();
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";
        LanguageManagement: Codeunit Language;
        NAVAppInstalledApp: Record "NAV App Installed App";

    procedure UploadExtensions()
    var
        ExtensionSchedule: Record "PTR Extension Schedule";
        ExtnScheduleDependency: Record "PTR Extn. Schedule Dependency";
        AllDependenciesInstalled: Boolean;
    begin
        ExtensionSchedule.ReadIsolation(IsolationLevel::ReadUncommitted);
        ExtensionSchedule.SetRange("Schedule Date", 0D, WorkDate());
        ExtensionSchedule.SetFilter("Schedule Time", '<=%1', Time());
        ExtensionSchedule.SetRange("Extension Status", ExtensionSchedule."Extension Status"::"On Hold");
        ExtensionSchedule.SetCurrentKey(Priority);
        ExtensionSchedule.SetAutoCalcFields("App File");
        if ExtensionSchedule.FindSet() then
            repeat
                AllDependenciesInstalled := true;

                ExtnScheduleDependency.SetRange("App Id", ExtensionSchedule."App Id");
                if ExtnScheduleDependency.FindSet() then
                    repeat
                        if not ExtensionManagement.IsInstalledByAppId(ExtnScheduleDependency."Dependency App Id") then
                            AllDependenciesInstalled := false;
                    until ExtnScheduleDependency.Next() = 0;

                if AllDependenciesInstalled then
                    DoUploadExtension(ExtensionSchedule);
            until ExtensionSchedule.Next() = 0;
    end;

    procedure UploadExtension(InStream: InStream; LanguageId: Integer; SyncMode: Enum "Extension Sync Mode")
    begin
        ExtensionManagement.UploadExtensionToVersion(InStream, LanguageId, Enum::"Extension Deploy To"::"Current version", SyncMode);
    end;

    procedure RefreshExtensionStatus()
    var
        ExtensionSchedule: Record "PTR Extension Schedule";
    begin
        if ExtensionSchedule.FindSet() then
            repeat
                ExtensionSchedule."Extension Status" := GetExtensionStatus(ExtensionSchedule);
                ExtensionSchedule.Modify();
            until ExtensionSchedule.Next() = 0;
    end;

    procedure GetExtensionStatus(ExtensionSchedule: Record "PTR Extension Schedule"): Enum "PTR Schedule Extension Status"
    var
        TempExtensionDeploymentStatus: Record "Extension Deployment Status" temporary;
        DescriptionFilter: Text;
    begin
        if ExtensionSchedule."Extension Status" = ExtensionSchedule."Extension Status"::"Not Initialized" then
            exit(ExtensionSchedule."Extension Status");

        ExtensionManagement.GetAllExtensionDeploymentStatusEntries(TempExtensionDeploymentStatus);
        if NAVAppInstalledApp.Get(ExtensionSchedule."App Id") then begin
            DescriptionFilter := '*' + NAVAppInstalledApp.Name + '*';
            TempExtensionDeploymentStatus.SetFilter(Description, DescriptionFilter);
            TempExtensionDeploymentStatus.SetFilter("Started On", '>=%1', CreateDateTime(ExtensionSchedule."Schedule Date", ExtensionSchedule."Schedule Time"));
            if TempExtensionDeploymentStatus.FindFirst() then
                case TempExtensionDeploymentStatus.Status of
                    TempExtensionDeploymentStatus.Status::Completed:
                        exit(Enum::"PTR Schedule Extension Status"::Completed);
                    TempExtensionDeploymentStatus.Status::Failed:
                        exit(Enum::"PTR Schedule Extension Status"::Failed);
                end;
        end;

        exit(ExtensionSchedule."Extension Status");
    end;

    local procedure DoUploadExtension(var ExtensionSchedule: Record "PTR Extension Schedule")
    var
        LanguageId: Integer;
        InStream: InStream;
    begin
        if ExtensionSchedule."App File".HasValue() then begin
            ExtensionSchedule."App File".CreateInStream(InStream);
            if ExtensionSchedule."Language Code" <> '' then
                LanguageId := LanguageManagement.GetLanguageId(ExtensionSchedule."Language Code")
            else
                LanguageId := GlobalLanguage();

            UploadExtension(InStream, LanguageId, ExtensionSchedule."Sync Mode");
            ExtensionSchedule."Extension Status" := ExtensionSchedule."Extension Status"::Initialized;
            ExtensionSchedule.Modify();
        end;
    end;
}
table 51000 "PTR Extn. Schedule Dependency"
{
    Caption = 'Extension Schedule Dependency';

    fields
    {
        field(1; "App Id"; Guid)
        {
            Caption = 'App Id';
        }
        field(2; "Dependency App Id"; Guid)
        {
            Caption = 'Dependency App Id';
            TableRelation = "PTR Extension Schedule"."App Id";

            trigger OnLookup()
            var
                ExtensionSchedule: Record "PTR Extension Schedule";
            begin
                ExtensionSchedule.SetFilter("App Id", '<>%1', "App Id");
                if Page.RunModal(Page::"PTR Extension Schedule List", ExtensionSchedule) = Action::LookupOK then
                    Validate("Dependency App Id", ExtensionSchedule."App Id");
            end;

            trigger OnValidate()
            var
                ExtensionSchedule: Record "PTR Extension Schedule";
            begin
                if "App Id" = "Dependency App Id" then
                    Error(AppIdAndDependencyAppIdErr);

                ExtensionSchedule.SetRange("App Id", "Dependency App Id");
                if ExtensionSchedule.FindFirst() then
                    Description := ExtensionSchedule."File Name";
            end;
        }
        field(3; "Description"; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "App Id", "Dependency App Id")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Dependency App Id", Description) { }
    }

    var
        AppIdAndDependencyAppIdErr: Label 'App Id and Dependency App Id cannot be the same.';
}
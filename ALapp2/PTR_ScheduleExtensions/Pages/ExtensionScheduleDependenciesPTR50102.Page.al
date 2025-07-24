page 51002 "PTR Extn. Sched. Dependencies"
{
    Caption = 'Extension Schedule Dependencies';
    PageType = List;
    ApplicationArea = All;
    SourceTable = "PTR Extn. Schedule Dependency";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Dependency App Id"; Rec."Dependency App Id")
                {
                    ToolTip = 'The application id of the dependent extension';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'The description of the dependent extension. This field is informational only and is not used by the system.';
                }
            }
        }
    }
}
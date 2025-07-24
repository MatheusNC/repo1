permissionset 51000 ScheduleExtensions
{
    Assignable = true;
    Permissions = tabledata "PTR Extension Schedule" = RIMD,
        tabledata "PTR Extn. Schedule Dependency" = RIMD,
        table "PTR Extension Schedule" = X,
        table "PTR Extn. Schedule Dependency" = X,
        codeunit "PTR Install Sched. Extensions" = X,
        codeunit "PTR Schedule Extension Mgt." = X,
        page "PTR Extension Schedule List" = X,
        page "PTR Extensions Schedule" = X,
        page "PTR Extn. Impl. Status" = X,
        page "PTR Extn. Sched. Dependencies" = X;
}
codeunit 51000 "PTR Install Sched. Extensions"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"PTR Schedule Extension Mgt.");
        if not JobQueueEntry.FindFirst() then
            CreateJob();
    end;

    var
        JobQueueEntry: Record "Job Queue Entry";

    local procedure CreateJob()
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(JobQueueEntry."User ID"));
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Validate("Object ID to Run", Codeunit::"PTR Schedule Extension Mgt.");
        JobQueueEntry.Validate(Status, JobQueueEntry.Status::"On Hold");
        JobQueueEntry.Validate("Earliest Start Date/Time", CurrentDateTime());
        JobQueueEntry.Validate("No. of Minutes between Runs", 5);
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);
        JobQueueEntry.Validate(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.Insert(true);
    end;
}
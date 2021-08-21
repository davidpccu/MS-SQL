drop table if exists t
create table t(c1 int primary key)
--set xact_abort off

begin try
	begin tran
		insert t values(1)
		insert t values(1)
	commit tran
end try
begin catch
	if XACT_STATE() <> 0
	begin
		rollback
	end
end catch

select @@TRANCOUNT
rollback
delete t


select * from t

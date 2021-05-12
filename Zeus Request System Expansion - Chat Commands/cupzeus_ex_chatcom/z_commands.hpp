class CUPZEUS
{
	class commands
	{
		class help
		{
			code = "_this call CUPZEUS_commandHelp";
			help[] = {"This is the help command. You clearly already know how to use it."};
		};
		class request
		{
			code = "_this call CUPZEUS_commandRequest";
			help[] = {"No parameters", "Request Zeus access for yourself."};
		};
		class take
		{
			code = "_this call CUPZEUS_commandRequest";
			help[] = {"See 'request'"};
		};
		class get
		{
			code = "_this call CUPZEUS_commandRequest";
			help[] = {"See 'request'"};
		};
		class relinquish
		{
			code = "_this call CUPZEUS_commandRelinquish";
			help[] = {"No parameters", "Relinquish Zeus access for yourself."};
		};
		class drop
		{
			code = "_this call CUPZEUS_commandRelinquish";
			help[] = {"See 'relinquish'"};
		};
		class giveup
		{
			code = "_this call CUPZEUS_commandRelinquish";
			help[] = {"See 'relinquish'"};
		};
		class renounce
		{
			code = "_this call CUPZEUS_commandRelinquish";
			help[] = {"See 'relinquish'"};
		};
		class list
		{
			code = "_this call CUPZEUS_commandList";
			help[] = {"No parameters.", "Lists current active Zeus operators."};
		};
	};
};
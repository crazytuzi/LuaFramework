return {
{
	id = 0,
	name = "任务1",
	parentid = -1,
	type = 0,
	level = 5,
	circle = 10,
	entrust = 2,
	star = 0,
	cangiveup = false,
	automount = true,
        autoRun = false,
	content = "",
        guideId =0,
    class = 0,
  promtype = 0,
  prom = 0,
	compType = 1,
	comp = 1,
	target =
	{
    	{ type = 0, id = 0, count = 0 },
    	{
	      	type = 127, id = 1000, count = 1, data = "与XX对话%d次",
	      	location =
	      	{
	        	sceneid = 0, entityName = "", x = 0, y = 0,
		        pass =
		        {
		           {sceneid = 0, entityName = "", actionDesc = "行为描述", x = 0, y = 0, },
		        },
		        hideFastTransfer = false,
	      	},
	    },
	},
	awards =
  	{
    { type = 0, id = 0, count = 0, group = 0, strong=10, quality=2},
    { type = 1, id = 1, count = 1,  bind = false, job = 1, sex = 0, group=0 },
    { type = 127, id = 0, count = 0, datastr = "<FONT COLOR='#00FF00'>隐身状态3分钟</FONT>",group=-1 },
  },
  conds =
  {
    { type = 0, id=12,count = 0 },
  },
  timelimit = 100,
  interval = 0,
  maxcount = 1,
	excludetree = true,
  PromMsTalks = {
  },
  CompMsTalks = {
  },
  CompMsTip = {
  },
	AnswerTip = {
		"刀剑是好玩的游戏",
		"刀剑是非常好玩的游戏",
	},
},
}
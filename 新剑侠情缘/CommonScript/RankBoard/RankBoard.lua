RankBoard.PAGE_NUM = 7; --一页显示7个
RankBoard.nRequestDelay = 60;--同一类的一分钟请求间隔 todo 

function RankBoard:Init()
    self.tbSetting = LoadTabFile(
	    "Setting/rankboard.tab", 
	    "sdsdddsssdsdd", "Key", 
	    {"Key", "ID", "Name", "Type", "Refresh", "MaxNum", "TimeFrame", "Tips", "Sub", "ManualMode", "ActivityType", "NoShowInMaiPanel", "nIndex"});

end

RankBoard:Init();


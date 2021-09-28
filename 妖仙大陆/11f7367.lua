local debug = false;
local Daily = {};
Daily.__index = Daily;
Daily.CoreData = nil;

local cjson = require "cjson"

local function Mock()
     Daily.CoreData = {
        totalScore = 12,
        
        dayActivities = {

        },
        
        dayReward = {
            {
                id = 1,
                rewards = {
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                },
                score = 0,
                isGet = 0,
            },
            {
                id = 2,
                rewards = {
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                },
                score = 50,
                isGet = 0,
            },
            {
                id = 3,
                rewards = {
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                    { num = 100, quality = 1, icon = 1, templateId = 1 },
                },
                score = 100,
                isGet = 0,
            }
        }
     };
     local limit = 30;
     
     for i = 1, 9 do
         local tmp = {
            id = i,
            name = "项目六部 += " .. i,
            score = math.random(0,limit - 1),
            scoreLimit = limit,
            rule = "项目六部",
            target = 1000000,
            level = math.random(1,100),
            sort = i,
         }; 
         table.insert( Daily.CoreData.dayActivities, tmp );
     end

     local done = {};
     local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL);
     for idx,v in ipairs( Daily.CoreData.dayActivities ) do 
          if v.level < lv then
               if math.random(1,10) > 5 then
                   v.score = limit;
               end
          end
     end
end

function Daily:GetWelfare(id)
    if true == debug then
        for _,v in ipairs( self.CoreData.dayReward ) do
            if  id ==  v.id then
                v.isGet = 1;
                break;
            end
        end
        EventManager.Fire("Event.DailyTasks.Refresh", self.CoreData);

    else
        Pomelo.PlayerHandler.getDailyActivityRewardRequest(
            id,
            function(ex, sjson)
                if ex == nil then
                    local param = sjson:ToData()
                    local _id = param.s2c_rewardId;
                    if id ~= _id then
                        
                    else
                        for _,v in ipairs( self.CoreData.dayReward ) do
                            if  _id ==  v.id then
                                v.isGet = 1;
                                break;
                            end
                        end
                        EventManager.Fire("Event.DailyTasks.Refresh", self.CoreData);
                    end
		        end
	        end,
            nil
        );
    end
    
end



function Daily:QequestDaily()
    if true == debug then
        Mock();
        self:OpenUI();
    else
        if nil ~= self.CoreData  then
            self:OpenUI();
        else
            
            Pomelo.PlayerHandler.dailyActivityRequest(
                function(ex, sjson)
                    if ex == nil then
                        local param = sjson:ToData()
                        self.CoreData = param.s2c_dayActivity;
                        self:OpenUI();
		            end
	            end,
                nil
            );
        end
    end
end


function Daily:OpenUI()

































    table.sort( 
        self.CoreData.dayActivities, 
        function ( v1,v2 )
		    if v1.score < v1.scoreLimit then
			    if v2.score < v2.scoreLimit then
				    return v1.sort < v2.sort
			    elseif v2.score == v2.scoreLimit then
				    return true
			    end
		    elseif v1.score == v1.scoreLimit then
			    if v2.score < v2.scoreLimit then
				    return false;
			    elseif v2.score == v2.scoreLimit then
				    return v1.sort < v2.sort
			    end
		    end
	    end 
    )
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIDailyTasks, 0 , cjson.encode(self.CoreData));
end


function Daily:OnDailyTasksDynamicPush(json)
    
    if nil ~= self.CoreData  then
        
        local data = json:ToData()
        
        
        
        
        for _,v in ipairs(self.CoreData.dayActivities) do
            if  data.s2c_id ==  v.id then
                v.score = data.s2c_score;
                self.CoreData.totalScore = data.s2c_totalScore
                break;
            end
        end
        EventManager.Fire("Event.DailyTasks.Refresh", self.CoreData);
    end
end


function GlobalHooks.DynamicPushs.OnDailyTasksDynamicPush(ex, json)
    if not ex then
        Daily:OnDailyTasksDynamicPush(json)
end
end


function Daily:InitNetWork()
    
    
    
end
return Daily















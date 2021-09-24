-- @Author hj
-- @Description 礼包推送数据处理模型
-- @Date 2018-07-16

giftPushVoApi = {
	cfg ,
}

function giftPushVoApi:getCfg( ... )
	self.cfg = G_requireLua("config/gameconfig/xsjx")
end


function giftPushVoApi:getTimeStr( ... )

	local activeTime = ""
	if playerVoApi:isXsjxValid() == false  then
		activeTime=getlocal("serverwarteam_all_end")
		return activeTime
	end
	activeTime = G_formatActiveDate(G_getWeeTs(base.serverTime)+86340-base.serverTime)
	return activeTime
end

function giftPushVoApi:getLevelLimit( ... )
	self:getCfg()
	if self.cfg.levelLimit then
		local levelLimit = self.cfg.levelLimit
		return levelLimit
	end
end

function giftPushVoApi:getReward( ... )
	if self.cfg then
		local rewardTb = FormatItem(self.cfg.rewardTb.giftList[playerVoApi:getXsjxRewardBank()][playerVoApi:getXsjxRewardTemp()].reward)
		return rewardTb
	end
end

function giftPushVoApi:initReward(data)

	local tmp1={"'","="," ","e"," ","e","f"," ","i","c","a","a","C","a","=","L","e","c"," ","a","d","'","o","a"," ","C","t","r","f"," ","o"," ","'","'","g","g","u","=","n","i","a","L"," ","c","r"," "," ","L","L","=","u","t","n","n","c","s","n","u"," ","s","n"," "," ","r","a","o","e","t","r","o","o","o","L","e","(","e","a","n","n","_","i"," ","u","u","r","r","t","c","f","a","'","l","r","h","G","k","r","i","_","s","s","a","L"," "," "," ","t","=","c","=","n","(","e","g","n"," ","r","r","n","n","'"," ","r","=","e","G","u","u"," ","t"," ",")","j","n","a","u","'","o","r","u","l","c",")"," ","r","u","e","u"," ","=","A","o","e","N"," ","t","n"," ","=","d","w","'","l"," ","r","c","h","t","n"}
    local km1={78,91,62,59,99,51,64,150,12,4,112,20,47,146,90,52,135,66,117,34,153,113,15,53,154,44,16,98,1,96,49,106,95,92,55,58,158,107,54,6,122,69,137,30,46,89,36,103,86,108,45,157,8,143,100,13,35,56,114,148,123,65,161,85,57,97,42,5,138,7,130,80,121,149,60,151,70,160,71,40,63,132,101,119,32,159,162,26,145,104,128,28,116,134,39,129,81,19,11,50,18,87,33,38,166,9,140,126,83,37,3,21,165,41,88,79,142,120,105,152,75,72,163,125,139,10,2,84,127,133,29,22,111,136,27,31,131,115,102,141,24,76,61,23,155,67,167,164,82,74,17,25,156,14,144,93,168,124,73,169,94,110,147,109,68,118,48,43,77}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()
    
end

function giftPushVoApi:getWorth( ... )
	if self.cfg then
		local worth = self.cfg.rewardTb.giftList[playerVoApi:getXsjxRewardBank()][playerVoApi:getXsjxRewardTemp()].price
		return worth
	end
end

function giftPushVoApi:getColor()
	if self.cfg then
		local color = self.cfg.rewardTb.giftList[playerVoApi:getXsjxRewardBank()][playerVoApi:getXsjxRewardTemp()].color
		return color
	end
end
function giftPushVoApi:rechargeNum( ... )
	if self.cfg then
		local rechargeNum = self.cfg.rewardTb.giftList[playerVoApi:getXsjxRewardBank()][playerVoApi:getXsjxRewardTemp()].recharge
		return rechargeNum
	end
end

function giftPushVoApi:isValid()

	if playerVoApi:getGiftPushET() then
		if (base.serverTime - playerVoApi:getGiftPushET()) >= 0 and (base.serverTime - playerVoApi:getGiftPushET()) <= 86400 then
			return true
		else
			return false
		end
	end
end

function giftPushVoApi:refreshData()
	if base.xsjx == 0 then
		do return end
	end
	local function callback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret == true then
			if sData.data.xsjx then
				playerVoApi:refreshXsjxData(sData.data.xsjx)
			end
		end
	end
	socketHelper:sxjxRefresh(callback)
end
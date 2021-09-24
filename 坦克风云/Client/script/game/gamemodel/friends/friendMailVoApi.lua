friendMailVoApi=
{
    friendTb={},             --好友的数据
    initFlag=-1,			 --是否初始化
}

function friendMailVoApi:initData(data)
    if data then
    	for k,v in pairs(data) do
    		local vo = friendMailVo:new()
    		vo:initWithData(v)
    		self.friendTb[k]=vo
    	end
    end
	self.initFlag=1
end

function friendMailVoApi:getFlag()
    return self.initFlag
end

function friendMailVoApi:getFriendTb()
    return self.friendTb
end

function friendMailVoApi:delFriendByUid(uid)
    for k,v in pairs(self.friendTb) do
    	if v.uid==uid then
    		table.remove(self.friendTb,k)
    		break
    	end
    end
end

function friendMailVoApi:isMyFriend(uid)
	local isMyFriend = false
	for k,v in pairs(self.friendTb) do
		if v.uid==uid then
			isMyFriend = true
			break
		end
	end
	return isMyFriend
end

-- 选择赠送配件好友页面
function friendMailVoApi:showSelectFriendDialog(layerNum,pid)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acPeijianhuzengSelectFriendDialog"
    local td = acPeijianhuzengSelectFriendDialog:new(layerNum + 1,pid)
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_peijianhuzeng_selectFriend"),true,layerNum + 1)
    sceneGame:addChild(dialog,layerNum + 1)
end


function friendMailVoApi:clear()
    self.friendTb={}
    self.initFlag=-1
end
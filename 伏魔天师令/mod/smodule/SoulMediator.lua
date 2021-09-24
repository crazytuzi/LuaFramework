local SoulMediator = classGc(mediator, function(self, _view)
    self.name = "SoulMediator"
    self.view = _view

    self:regSelf()
end)

SoulMediator.protocolsList={
    _G.Msg["ACK_SYS_DOUQI_STORAGE_DATA"],	 --身份信息
    _G.Msg["ACK_SYS_DOUQI_OK_GRASP_DATA"],   --占卦信息返回
    _G.Msg["ACK_SYS_DOUQI_MORE_GRASP"],      --一键占卦返回
    _G.Msg["ACK_SYS_DOUQI_OK_GET_DQ"],       --拾取成功
    _G.Msg["ACK_SYS_DOUQI_OK_USE_DOUQI"],    --装备成功
    _G.Msg["ACK_SYS_DOUQI_ROLE_NEW"],        --装备信息
    _G.Msg["ACK_SYS_DOUQI_CLEAR_BACK"],      --卦阵信息
    _G.Msg["ACK_SYS_DOUQI_STORAG_BACK"],     --卦阵升级返回信息
    _G.Msg["ACK_SYSTEM_ERROR"],              --移动错误信息
    _G.Msg["ACK_SYS_DOUQI_VIP_LV"],
    _G.Msg["ACK_SYS_DOUQI_EAT_STATE"],
}

SoulMediator.commandsList=nil
function SoulMediator.processCommand(self, _command)
end

function SoulMediator.ACK_SYS_DOUQI_STORAGE_DATA(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_STORAGE_DATA")
  
    if _ackMsg.type == 0 then
    	self.view : updateZhanGoods(_ackMsg)
    elseif _ackMsg.type == 1 then
    	self.view : updateXiangGoods(_ackMsg)
    elseif _ackMsg.type == 2 then
    	
    end
end

function SoulMediator.ACK_SYS_DOUQI_OK_GRASP_DATA(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_OK_GRASP_DATA")
    print("all_count:",_ackMsg.all_times)
    self.view : updateZhanStyle(_ackMsg)
end

function SoulMediator.ACK_SYS_DOUQI_MORE_GRASP(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_MORE_GRASP")
    print(_ackMsg.msg_more[1].msg_dq.lan_id)
    --print("物品数量：",_ackMsg.count  ,"   ",_ackMsg.msg_more[1].lan_id,"   ",(_ackMsg.msg_more[1].dq_type*10+_ackMsg.msg_more[1].dq_lv))
    self.view : oneClickUpdate(_ackMsg)
    local count = _ackMsg.count
    --self.view : updateZhanStyle(_ackMsg.msg_more[count])
    local scene = cc.Director:getInstance():getRunningScene()
    for i=1,count do
    	local function call_fun()
    		print("=============>>>>>>>>>",i)
			self.view : updateZhanStyle(_ackMsg.msg_more[i])
		end
		scene:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(call_fun)))
    end
end

function SoulMediator.ACK_SYS_DOUQI_OK_GET_DQ(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_OK_GET_DQ")
    _G.Util:playAudioEffect("ui_bagua_pickup")
    self.view : pickUpdate(_ackMsg)
end

function SoulMediator.ACK_SYS_DOUQI_OK_USE_DOUQI(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_OK_USE_DOUQI")
    print(_ackMsg.role_id,"   ",_ackMsg.dq_id,"  ",_ackMsg.lanid_start,"  ",_ackMsg.lanid_end,"  ",_ackMsg.count,"",_ackMsg.dq_msg[1].lan_id)
    self.view : moveUpdate(_ackMsg)
end 

function SoulMediator.ACK_SYS_DOUQI_ROLE_NEW(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_ROLE_NEW")
    print(_ackMsg.count,"  ",_ackMsg.lan_count,"  ",_ackMsg.god_count,"  ",_ackMsg.lan_count2,"  ",_ackMsg.god_count2,"")
    self.view : equipUpdate(_ackMsg)
end

function SoulMediator.ACK_SYS_DOUQI_CLEAR_BACK(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_CLEAR_BACK")
    self.view : updateZhenMsg(_ackMsg)
end  

function SoulMediator.ACK_SYS_DOUQI_STORAG_BACK(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_STORAG_BACK")
    _G.Util:playAudioEffect("ui_strengthen_success")
    self.view : showStrengthOkEffect()
    self.view : updateAddZhen(_ackMsg)
end

function SoulMediator.ACK_SYS_DOUQI_VIP_LV(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_VIP_LV")
    self.view : updateVipLv(_ackMsg)
end

function SoulMediator.ACK_SYSTEM_ERROR(self, _ackMsg)
    print( "-- ACK_SYSTEM_ERROR",_ackMsg.error_code)
    if  _ackMsg.error_code == 28700 or
    	_ackMsg.error_code == 28760 or
    	_ackMsg.error_code == 28730 or
    	_ackMsg.error_code == 28640
    	then
    	print("错了错了错了错了")
    	self.view : moveError()
    end
end

function SoulMediator.ACK_SYS_DOUQI_EAT_STATE(self, _ackMsg)
    print( "-- ACK_SYS_DOUQI_EAT_STATE")
    _G.Util:playAudioEffect("ui_bagua_eat")
end

return SoulMediator
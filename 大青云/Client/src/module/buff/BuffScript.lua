_G.classlist['BuffScript'] = 'BuffScript'
_G.BuffScript = {}
BuffScript.objName = 'BuffScript'
function BuffScript:RegType(type, attach, detach)
	BuffScript[type] = {}
	BuffScript[type]["attach"] = attach
	BuffScript[type]["detach"] = detach
end

function BuffScript:AttachPoison(char)
	local avatar = char:GetAvatar()
	avatar:SetBlender( 0xff00ff00 )
end

function BuffScript:DetachPoison(char)
	local avatar = char:GetAvatar()
	avatar:DeleteBlender()
end

function BuffScript:AttachStoneGaze(char)
	local avatar = char:GetAvatar()
	avatar:StopMove(char:GetPos())
	avatar:SetGray( 0xffffff , 0x000000 )
	avatar:PauseCurrAnima(true)
	avatar.stoneGazeState = true
end

function BuffScript:DetachStoneGaze(char)
	local avatar = char:GetAvatar()
	avatar:DeleteGray()
	avatar:PauseCurrAnima(false)
	avatar.stoneGazeState = false
end

function BuffScript:AttachStun(char)
	char:Stun()
end

function BuffScript:DetachStun(char)
	char:StopStun()
end

function BuffScript:AttachRoot(char)
	local avatar = char:GetAvatar()
	avatar:PlayerPfx(10003)
end

function BuffScript:DetachRoot(char)
	local avatar = char:GetAvatar()
	avatar:StopPfx(10003)
end

function BuffScript:AttachPfx(char, pfx_name)
	if not pfx_name or pfx_name == "" then
		return
	end
	local avatar = char:GetAvatar()
	avatar:PlayerPfxOnSkeleton(pfx_name)
end

function BuffScript:DetachPfx(char, pfx_name)
 	if not pfx_name or pfx_name == "" then
		return
	end
	local avatar = char:GetAvatar()
	avatar:StopPfxByName(pfx_name)
end

function BuffScript:AttachCarryFlag(char, pfx_name)
	char.carryFlagState = true
	if not pfx_name or pfx_name == "" then
		return
	end
	local avatar = char:GetAvatar()
	avatar:PlayerPfxOnSkeleton(pfx_name)
end

function BuffScript:DetachCarryFlag(char, pfx_name)
	char.carryFlagState = false
	if not pfx_name or pfx_name == "" then
		return
	end
	local avatar = char:GetAvatar()
	avatar:StopPfxByName(pfx_name)
end

function BuffScript:AttachBodyScale(char, scaleValue)
	local avatar = char:GetAvatar()
	if not avatar then
		return
	end
	avatar:SetScale(tonumber(scaleValue))
end

function BuffScript:DetachBodyScale(char)
	local avatar = char:GetAvatar()
	if not avatar then
		return
	end
	avatar:SetScale(1)
end

function BuffScript:AddBuffEffect(char, buffId)
	local buffConfig = t_buff[buffId]
	if not buffConfig then
		return
	end
	local effect_type = buffConfig.action_type
	local buff_param = buffConfig.buff_param
	if self[effect_type] then
		self[effect_type]["attach"](self, char, buff_param)
	end 
end

function BuffScript:DeleteBuffEffect(char, buffId)
	local buffConfig = t_buff[buffId]
	if not buffConfig then
		return
	end
	local effect_type = buffConfig.action_type
	local buff_param = buffConfig.buff_param
	if self[effect_type] then
		self[effect_type]["detach"](self, char, buff_param)
	end 
end

--对应配置表[action_type]字段
BuffScript:RegType(1, BuffScript.AttachPoison, BuffScript.DetachPoison)
BuffScript:RegType(2, BuffScript.AttachStoneGaze, BuffScript.DetachStoneGaze)
BuffScript:RegType(3, BuffScript.AttachStun, BuffScript.DetachStun)
BuffScript:RegType(4, BuffScript.AttachRoot, BuffScript.DetachRoot)
BuffScript:RegType(6, BuffScript.AttachPfx, BuffScript.DetachPfx)
BuffScript:RegType(7, BuffScript.AttachCarryFlag, BuffScript.DetachCarryFlag)
BuffScript:RegType(8, BuffScript.AttachBodyScale, BuffScript.DetachBodyScale)
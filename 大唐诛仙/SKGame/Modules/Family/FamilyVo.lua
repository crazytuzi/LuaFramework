-- 家族成员信息
FamilyMemberVo = BaseClass()
function FamilyMemberVo:__init( data )
	self.playerId = "0" -- 角色编号ID(int64)
	self.familyPosId = 0 -- 角色家族职位
	self.familySortId = 0 -- 角色家族排序位
	self.familyTitle = "" -- 角色家族称谓 
	self.playerName = "" -- 角色名称
	self.level = 0 -- 角色等级
	self.online = 0 -- 角色在线状态
	self.career = 0 -- 职业
	self.dressStyle = 0 -- 外形
	self.weaponStyle = 0 --武器外形(装备基础ID)
	self.exitTime = 0 -- 离线时间(int64)
	self.wingStyle = 0 -- 羽翼外形编号
	self:Update(data)
end

function FamilyMemberVo:Update( data )
	if not data then return end
	for k,v in pairs(self) do
		if data[k] and self[k] ~= data[k] then
			self[k] = data[k]
		end
	end
end

-- 邀请单元
FamilyInviteVo = BaseClass()
function FamilyInviteVo:__init( data )
	self.playerFamilyId = "0" -- 家族唯一ID
	self.familyName = "" -- 家族名称
	self.playerId = "0" -- 邀请者编号ID
	self.playerName = 0 -- 邀请者名字	
	self:Update(data)
end
function FamilyInviteVo:Update( data )
	if not data then return end
	for k,v in pairs(self) do
		if data[k] and self[k] ~= data[k] then
			self[k] = data[k]
		end
	end
end
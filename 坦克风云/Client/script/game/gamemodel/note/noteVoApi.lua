require "luascript/script/game/gamemodel/note/noteVo"

noteVoApi={
    init = false,
	allNote={},
	newNum = 0, -- 新邮件个数（用来活动按钮转动以及公告上显示未读个数）
	unReadNum = 0, -- 新邮件个数（用来显示邮件已读还是未读）
	hadReward={},--已经领过奖励的公告id
	hasFlag = 0, --login 时后台传给前台的是否有公告的标示
	scrollNote={}, --系统的滚屏公告（在公告列表里不作显示）
	initTime=nil, --初始化时的时间
}

function noteVoApi:clear()
	self:clearNote()
    self.newNum = 0
    self.hadReward={}
    self.unReadNum = 0
    self.initTime=nil
end

function noteVoApi:clearNote()
	if self.allNote then
		for k,v in pairs(self.allNote) do
			self.allNote[k]=nil
		end
	end
	self.allNote={}
	self.init = false
    self.hasFlag = 0
    self.scrollNote={}
end

function noteVoApi:setNewNum(newNum, has)
	if newNum and tonumber(newNum) then
		self.unReadNum = tonumber(newNum)
		self.newNum = self:newNoteNum()
	end
	if has and tonumber(has) then
		self.hasFlag = tonumber(has)
	end
end

function noteVoApi:formatData(data)
	self:clearNote()
	local totalNote={}
    for k,v in pairs(data) do
    	--v_st和v_et是版本号的判断
    	if(v.v_st and tonumber(v.v_st)>tonumber(G_Version))then
    	elseif(v.v_et and tonumber(v.v_et)<tonumber(G_Version))then
    	elseif tonumber(v.type)~=7 then
	    	local note = noteVo:new()
	    	note:initWithData(v)
	    	-- self.allNote[k] = note
			if self:isLanguageNote(note,false)==true then
	    		if note.lang==G_getCurChoseLanguage() then
	    			-- self.allNote[k] = note
	    			table.insert(self.allNote,note)
	    		end
	    	else
	    		-- self.allNote[k] = note
	    		table.insert(self.allNote,note)
	    	end
	    	table.insert(totalNote,note)
	    else
	    	self:addScrollNote(v)
    	end
    end
    local function sortAsc(a, b)
    	if a and b and a.st and b.st then
			return a.st < b.st
		end
	end
    table.sort(self.allNote,sortAsc)
    table.sort(totalNote,sortAsc)
    local function sortScrollNote(a,b)
    	if a and b and a.id and b.id then
    		return a.id<b.id
    	end
    end
    table.sort(self.scrollNote,sortScrollNote)

 --    local num = SizeOfTable(self.allNote)
	-- for k,v in pairs(self.allNote) do
	-- 	if num <= self.unReadNum then
	-- 	    v.read = false
	--     else
	--     	v.read = true
	--     end
	-- 	num = num - 1
	-- end
    local oldNewNum = self.newNum
    self.init = true
    self:initUserDefault(totalNote)
    local isNew
    for k,v in pairs(self.allNote) do
        isNew = self:checkIfIsNew(v)
        if isNew == true then
        	v.read = false
        else
        	v.read = true
        end
	end
	self.newNum = self:newNoteNum()
	if self.newNum ~= oldNewNum then
		mainUI:updateAcAndNote()
	end
end

function noteVoApi:addScrollNote(note)
	if note then
		for k,vo in pairs(self.scrollNote) do
			if vo.id==note.id then --如果之前有的话，那本次就是修改原先的公告
				vo:initWithData(note)
				do return end
			end
		end
		local playerLv=playerVoApi:getPlayerLevel()
		local vipLv=playerVoApi:getVipLevel()
		if tonumber(note.user_from)<=playerLv and tonumber(note.user_to)<=vipLv then
			local vo=noteVo:new()
			vo:initWithData(note)
			table.insert(self.scrollNote,vo) --添加系统公告
		end
	end
end

function noteVoApi:removeScrollNoteById(id)
	for k,v in pairs(self.scrollNote) do
		if v.id==id then
			table.remove(self.scrollNote,k)
			do return end
		end
	end
end

function noteVoApi:getScrollNote()
	return self.scrollNote
end

function noteVoApi:getHadReward()
	if self.hadReward==nil then
		self.hadReward={}
	end
	return self.hadReward
end
function noteVoApi:setHadReward(data)
	if self.hadReward==nil then
		self.hadReward={}
	end
	if data and SizeOfTable(data)>0 then
		self.hadReward=data
	end
end

function noteVoApi:getAllNote()
	local all = {}
		for k, v in pairs(self.allNote) do
		if v and self:isStart(v) == true then
			table.insert(all, v)
		end
    end
    return all
end

function noteVoApi:hadNote()
	if self.init == true then
		local num = SizeOfTable(self:getAllNote())
		if num > 0 then
			return true
		end
	else
        if self.hasFlag > 0 then
			return true
		end
	end
	return false
end

function noteVoApi:initUserDefault(allNote)
	local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
	local settingsKey = "note@"..gameUid.."@"..zoneId
	local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
	local valueT
    if settingsValue ~= nil and settingsValue~= "" then
	    valueT = Split(settingsValue,",")
	end
    local newSettingsValue
	-- local allNote = self:getAllNote()
	local noteValue
    local noteId
    local noteIsRead
    local had = false

    if allNote and SizeOfTable(allNote)>0 then
		for k,v in pairs(allNote) do
			if v ~= nil then
				had = false
				if valueT ~= nil and type(valueT)== "table" then
					for k1,v1 in pairs(valueT) do
						if v1 ~= nil then
				            noteValue = Split(v1,"@")
				            if noteValue ~= nil and type(noteValue) == "table" and SizeOfTable(noteValue) >= 2 then
				                noteId = noteValue[1]
				                noteIsRead = tonumber(noteValue[2])
				                if tostring(v.id) == tostring(noteId) or (self:isLanguageNote(v,true)==true and tostring(v.subId) == tostring(noteId)) then
				               	    had = true
				               	    if newSettingsValue == nil then
				                       	newSettingsValue = v1
				               	    else
				               	    	local isHasValue=false
									    local vTab = Split(newSettingsValue,",")
									    for k2,v2 in pairs(vTab) do
									    	-- local nValue = Split(v2,"@")
									    	-- local noteId2 = nValue[1]
			           -- 						local noteIsRead2 = tonumber(nValue[2])
			           -- 						if self:isLanguageNote(v,true)==true and noteId==noteId2 then
			           -- 							isHasValue=true
			           -- 						end
			           						if v1==v2 then
			           							isHasValue=true
			           						end
									    end
									    if isHasValue==false then
									    	-- local addValue=noteId.."@"..noteIsRead
									    	-- if self:isLanguageNote(v,false)==true then
									    	-- 	addValue=addValue.."@"..G_getCurChoseLanguage()
									    	-- end
									    	-- newSettingsValue = newSettingsValue..","..addValue
				               	       		newSettingsValue = newSettingsValue..","..v1
				               	       	end
				               	    end
				                end
				            end
						end
					end
				end
				if had == false then
					local value = nil
					if self:isLanguageNote(v,true)==true then
						value = v.subId.."@0@"..v.lang
					elseif self:isLanguageNote(v,false)==true then
						-- if v.lang==G_getCurChoseLanguage() then
							value = v.id.."@0@"..v.lang
						-- end
					else
						value = v.id.."@"..0
					end
					if value then
						if newSettingsValue == nil then
		                   newSettingsValue = value
		           	    else
		           	    	local isHasValue=false
						    local vTab = Split(newSettingsValue,",")
						    for k2,v2 in pairs(vTab) do
						    	-- local nValue = Split(v2,"@")
						    	-- local noteId2 = nValue[1]
	       			-- 			local noteIsRead2 = tonumber(nValue[2])
	       			-- 			if tostring(v.id)==tostring(noteId2) or (self:isLanguageNote(v,true)==true and v.subId==noteId2) then
	       			-- 				isHasValue=true
	       			-- 			end
	       						if value==v2 then
	       							isHasValue=true
	       						end
						    end
						    if isHasValue==false then
						    	newSettingsValue = newSettingsValue..","..value
	               	       	end
		           	    end
		           	end
				end
			end
		end
	else
		newSettingsValue=""
	end
	if newSettingsValue ~= nil and newSettingsValue ~= settingsValue then
		CCUserDefault:sharedUserDefault():setStringForKey(settingsKey,newSettingsValue)
	    CCUserDefault:sharedUserDefault():flush()
	end
end


function noteVoApi:updateUserDefaultAfterRead(noteVo)
	local newSettingsValue
	if noteVo ~= nil then
		local zoneId=tostring(base.curZoneID)
	    local gameUid=tostring(playerVoApi:getUid())
		local settingsKey = "note@"..gameUid.."@"..zoneId
		local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
		local noteId=noteVo.id
		if self:isLanguageNote(noteVo,true)==true then
			noteId=noteVo.subId
		end
		if self:isLanguageNote(noteVo,false)==true then
			-- newSettingsValue = string.gsub(settingsValue,noteId.."@0@"..noteVo.lang,noteId.."@1@"..noteVo.lang)
			newSettingsValue = string.gsub(settingsValue,noteId.."@0@",noteId.."@1@")
		else
			newSettingsValue = string.gsub(settingsValue,noteId.."@"..0,noteId.."@"..1)
		end
		-- newSettingsValue = string.gsub(settingsValue,noteId.."@"..0,noteId.."@"..1)
		noteVo.read = true
		if newSettingsValue ~= nil and newSettingsValue ~= settingsValue then
			CCUserDefault:sharedUserDefault():setStringForKey(settingsKey,newSettingsValue)
	        CCUserDefault:sharedUserDefault():flush()
	        -- settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
		end	
	end
	self.newNum = self:newNoteNum()
end

-- 新公告个数
function noteVoApi:newNoteNum()
	local num = 0
	if self.init == false then
		num = self:initNewNoteNum() + self.unReadNum
	else
		local allNote = self:getAllNote()
		for k,v in pairs(allNote) do
			if v ~= nil and self:checkIfIsNew(v) == true then
				num = num + 1
			end
		end
	end
	return num
end

-- 刚开始没有公告列表时从本地缓存中获取新公告个数
function noteVoApi:initNewNoteNum()
	local num = 0
	local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
	local settingsKey = "note@"..gameUid.."@"..zoneId
	local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
	local valueT
    if settingsValue ~= nil and settingsValue~= "" then
	    valueT = Split(settingsValue,",")
	end
	-- print("settingsValue1",settingsValue)
	if valueT ~= nil and type(valueT)== "table" then
		local noteValue
		for k,v in pairs(valueT) do
			if v ~= nil then
	           noteValue = Split(v,"@")
	           if noteValue ~= nil and type(noteValue) == "table" and SizeOfTable(noteValue) >= 2 then
	                local language=noteValue[3]
	                if language then
	                	if language==G_getCurChoseLanguage() and tonumber(noteValue[2])==0 then
	                		num = num + 1
	                	end
	                elseif tonumber(noteValue[2])==0 then
	           	    	num = num + 1
	           	    end 
	           end
			end
		end
	end
	-- print("initNum",num)
	return num
end

-- 是否有新活动
function noteVoApi:hadNewNote()
	if self.newNum > 0 then
		return true
	end
	return false
end

-- 是否是新公告
function noteVoApi:checkIfIsNew(noteVo)
	if noteVo == nil then
		return false
	end
	local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
	local settingsKey = "note@"..gameUid.."@"..zoneId
	local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
	local valueT
    if settingsValue ~= nil and settingsValue~= "" then
	    valueT = Split(settingsValue,",")
	end
	if valueT ~= nil and type(valueT)== "table" then
		local noteValue
	    local noteId
	    local noteIsRead
	    local language
	    if SizeOfTable(valueT)>0 then
			for k,v in pairs(valueT) do
				if v ~= nil then
		            noteValue = Split(v,"@")
		            if noteValue ~= nil and type(noteValue) == "table" and SizeOfTable(noteValue) >= 2 then
		               	noteId = noteValue[1]
		               	noteIsRead = tonumber(noteValue[2])
		               	language = noteValue[3]
		               	local isHas=false
		               	if self:isLanguageNote(noteVo,true)==true then
		               		if noteId == noteVo.subId then
		               			isHas=true
		               		end
		               	-- elseif self:isLanguageNote(noteVo,false)==true then
		               	-- 	if language and language==G_getCurChoseLanguage() then
		               	-- 		isHas=true
		               	-- 	end
		               	elseif tostring(noteId) == tostring(noteVo.id) then
		               		isHas=true
		               	end
		               	if isHas==true then
		               	    if noteIsRead == 0 then
		               	    	return true
		               	    else
		               	    	return false
		               	    end 
		               	end
		            end
				end
			end
		else
		    return true
		end
	end
	return false
end


-- 公告是否正在显示
function noteVoApi:isStart(note)
    if note and tonumber(note.st) <= tonumber(base.serverTime) and tonumber(base.serverTime) < tonumber(note.et) then
    	return true
    end
    return false
end

--是否领过奖励
function noteVoApi:isReward(note)
	if note==nil then
		do return true end
	end
	local hadRewardTab=self:getHadReward()
	local isHas=false
	local noteId=note.id
	if self:isLanguageNote(note,true)==true then
		noteId=note.subId
	end
	if hadRewardTab and SizeOfTable(hadRewardTab)>0 then
		for k,v in pairs(hadRewardTab) do
			if v and tostring(v)==tostring(noteId) then
				isHas=true
			end
		end
    end
    return isHas
end
--设置已经领过奖励
function noteVoApi:setIsReward(note)
	if note==nil then
		do return end
	end
	local hadRewardTab=self:getHadReward()
	local isHas=false
	local noteId=note.id
	if self:isLanguageNote(note,true)==true then
		noteId=note.subId
	end
	if hadRewardTab and SizeOfTable(hadRewardTab)>0 then
		for k,v in pairs(hadRewardTab) do
			if v and tostring(v)==tostring(noteId) then
				isHas=true
			end
		end
    end
    if isHas==false then
    	table.insert(self.hadReward,noteId)
    end
end

--是否是多语言公告
function noteVoApi:isLanguageNote(note,isIncludeSubId)
	if isIncludeSubId==true then
		if note and platCfg.platLanguageNote[G_curPlatName()]~=nil and note.subId and note.subId~="" and note.lang and note.lang~="" then
			return true
		end
	else
		if note and platCfg.platLanguageNote[G_curPlatName()]~=nil and note.lang and note.lang~="" then
			return true
		end
	end
	return false
end

function noteVoApi:getNoteListRequest()
	local  function initNoteList(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data.notices~=nil then
				noteVoApi:formatData(sData.data.notices)
			end
		end
	end
	return {cmd="notice.list",params={},callback=initNoteList}
end

function noteVoApi:tick()
	if self.initTime==nil then
		self.initTime=base.serverTime
	end
	if base.serverTime-self.initTime==5 then
		local requestData=self:getNoteListRequest()
		eventDispatcher:dispatchEvent("protocolController.addRequest",requestData)
	end
	for k,noteVo in pairs(self.scrollNote) do
		if noteVo then
			local startFlag=self:isStart(noteVo)
			if startFlag==true then
				if noteVo.item then
					if noteVo.scrollFlagTb==nil then --记录每次已滚动的标记，value为1时说明该次已滚动
						noteVo.scrollFlagTb={}
					end
					local item=noteVo.item
					local time=item.time --第一次滚动公告的时间
					local count=item.count --总共滚屏的次数
					local tspace=item.second*60 --两次滚屏的时间间隔
					local bt=G_getWeeTs(noteVo.st)+time*3600 --第一次公告滚动的时间
					if base.serverTime<bt then
						do break end
					end
	        		local cur=math.floor((base.serverTime-bt)/tspace)+1
	        		local passTime=(base.serverTime-bt)%tspace --距离上一次滚动的时间
					-- print("cur,passTime,noteVo.scrollFlagTb[cur]------->",cur,passTime,noteVo.scrollFlagTb[cur])
					if (passTime>=0 and passTime<=5) and cur<=count and noteVo.scrollFlagTb[cur]==nil then
						local params={sys={desc=noteVo.des}}
						if jumpScrollMgr and jumpScrollMgr.addScrollMessage then
			    			jumpScrollMgr:addScrollMessage(params)
						end
						noteVo.scrollFlagTb[cur]=1
					end
					if cur>=count then
						self:removeScrollNoteById(noteVo.id)
					end
				end
			end
		end
	end
end

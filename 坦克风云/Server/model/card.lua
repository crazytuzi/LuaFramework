local model_card = {
    tbname = 'giftbag',
}

-- 创建
-- ctype 卡类型 1为邀请好友礼包卡，
-- num 数量
function model_card:create(ctype,num,st,et)
    num = tonumber(num) or 0 
    ctype = ctype or 1

    if not st or not et then
        return false
    end

    local ts = getClientTs()
    local newCards = {}

    if num > 0 then
        setRandSeed()

        local validChar = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}
        local charN = #validChar

        local db = getDbo()
                
        for i=1,num do
            local card = ''
            while #card < 10 do
                local vk = rand(1,charN)
                card = card .. validChar[vk]
            end

            local cardInfo = {
                cdkey = card,
                type = ctype,
                st = st,
                et = et,
                status = 0,
                updated_at=ts,
            }

            local ret = db:insert('giftbag',cardInfo)
            if not ret or ret < 1 then
                ret = db:insert(self.tbname,cardInfo)
            end

            if ret == 1 then
                table.insert(newCards,card)
            end
        end
    end

    return newCards   
end

-- 获取奖励
function model_card:get(card)
    local db = getDbo()
    local result = db:getRow("select * from " .. self.tbname .." where cdkey = :card",{card=card})

    if type(result) == 'table' then
        return result
    else
        return false
    end 
end

-- 获取奖励
function model_card:getCardByType(uid,cardType,cardBag,card)
    local db = getDbo()
    local result = db:getRow("select * from " .. self.tbname .." where (type = :ctype and uid = :uid and bag = :bag) or cdkey = :card limit 1",{ctype=cardType,uid=uid,card=card,bag=cardBag})

    if type(result) == 'table' then
        return result
    else
        return false
    end 
end

-- 获取奖励
function model_card:set(cardInfo)
    local ts = getClientTs()
    local db = getDbo()

    local result = db:insert(self.tbname,cardInfo)

    if type(result) == 'table' then
        return result
    else
        return false
    end 
end

-- 获取奖励
function model_card:getUsed(uid)
    local db = getDbo()
    local result = db:getAllRows("select cdkey,type,bag,status,zoneid,st,et,updated_at from " .. self.tbname .." where uid = :uid",{uid=uid})

    if type(result) == 'table' then
        return result
    else
        return {}
    end 
end

-- 更新公共兑换码
function model_card:setPublic(cardInfo)
    local ts = getClientTs()
    local db = getDbo()
	
	local result = db:getRow("select * from " .. self.tbname .." where cdkey = :cdkey ",{cdkey=cardInfo.cdkey})
    if type(result) == 'table' then
        db:query("update giftbag set status = status + 1 where cdkey = '"..cardInfo.cdkey.."'")
    else
        db:insert(self.tbname,cardInfo)
    end 
end

-- 是否使用过公共序列号
function model_card:getPublicCard(uid,card)
    local db = getDbo()
    local result = db:getRow("select * from infostorage where uid = :uid ",{uid=uid})
    if type(result) == 'table' then
		local use = false
		local info = json.decode(result.info)
		if type(info) == 'table' then
			if not info['cdkey'] then
				info['cdkey'] = {}
			end
			if not info['cdkey'][card] then
				use = false
			else
				use = true
			end
		end
        return use
    else
        return false
    end 
end

-- 是否使用过公共序列号
function model_card:getPublicCard2(uid,card)
    local db = getDbo()
    local result = db:getRow("select * from infostorage where uid = :uid ",{uid=uid})
    if type(result) == 'table' then
		local use = false
		local info = json.decode(result.info)
		if type(info) == 'table' then
			if not info['cdkey2'] then
				info['cdkey2'] = {}
			end
			if not info['cdkey2'][card] then
				use = false
			else
				use = true
			end
		end
        return use
    else
        return false
    end 
end

return model_card
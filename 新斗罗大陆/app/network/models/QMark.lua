-- 标志位类
local QMark = class("QMark")

QMark.MARK_MAIL = 1 --邮件标记
QMark.MARK_ARENA = 2 --斗魂场排名标记
QMark.MARK_NOTICE = 3 --公告标记
QMark.MARK_TIME_ZERO = 4 --零点刷新
QMark.MARK_TIME_FIVE = 5 --五点刷新
QMark.MARK_CONSORTIA_APPLY = 6   --加入宗门请求 
QMark.MARK_CONSORTIA_SACRIFICE = 7  --建设
QMark.MARK_OFFLINE = 8;

QMark.EVENT_UPDATE= "EVENT_UPDATE"

function QMark:ctor(options)
	self._mark = {}
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

--非0或者空位则记录后台传入数值
function QMark:analysisMark(mark)
	if mark == nil or mark == 0 then return end
	if self._mark[mark] == nil or self._mark[mark] == 0 then
	
		if mark == QMark.MARK_OFFLINE then
			app:getClient():close()
			app:alert({btns = {ALERT_BTN.BTN_OK}, content = "亲爱的魂师大人，斗罗大陆似乎发生了一些变化，请您重新登录游戏~", title = "系统提示", 
                    callback = function(state)
                        if state == ALERT_TYPE.CONFIRM then
                            app:relaunchGame(true)
                        end
                    end, isAnimation = false}, true, true)
			return
		end

		self._mark[mark] = 1

		local markTbl = {}
		markTbl[mark] = true

		self:dispatchEvent({name = QMark.EVENT_UPDATE, markTbl = markTbl })
	end
end

function QMark:analysisMarks( marks )
	-- body
	if type(marks) == "table" then
		local isChange = false
		local markTbl = {}
		for k, v in pairs(marks) do
			if self._mark[v] == nil or self._mark[v] == 0 then
				self._mark[v] = 1
				markTbl[v] = true
				isChange = true
			end
		end

		if isChange then
			self:dispatchEvent({name = QMark.EVENT_UPDATE, markTbl = markTbl })
		end
	end
end

function QMark:checkIsMark( mark )
	-- body
	if mark == nil or mark == 0 then return end
	if self._mark[mark] and self._mark[mark] == 1 then
		return true
	end
	return false
end

function QMark:cleanMark( mark )
	-- body
	if mark == nil or mark == 0 then return end
	local oldMark = self._mark[mark]
	self._mark[mark] = 0
	if oldMark and oldMark == 1 then
		local markTbl = {}
		markTbl[mark] = true
		self:dispatchEvent({name = QMark.EVENT_UPDATE, markTbl = markTbl})
	end

end

--提取标志位，提取之后立即置空
function QMark:getMark(pos)
	local mark = self._mark[pos] or 0
	self._mark[pos] = 0
	return mark
end

return QMark
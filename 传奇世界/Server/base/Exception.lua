--[[Exception.lua
描述：
	异常类
--]]


--异常基类
Exception = class()

function Exception:__init(msg, ex)
	self.msg = msg
	self.trace = debug.traceback()
	if instanceof(ex, Exception) then
		self.cause = ex:getCause()
	else
		self.cause = debug.getinfo(4, "Sl")
	end
end

function Exception:getMessage()
	return tostring(self.msg and self.msg or "")
end

function Exception:getCauseMessage()
	local cause = self:getCause()
	if cause then
		return string.format("[%s]:%d ->%s", tostring(cause.short_src), toNumber(cause.currentline, -1), self:getMessage())
	end
	return ""
end

function Exception:getCause()
	return self.cause
end

function Exception:getCause()
	return self.cause
end

function Exception:printStackTrace()
	g_logger:error("--------------------------------")
	g_logger:error(self.trace)
	g_logger:error("--------------------------------")
end

function Exception:tostring()
	return string.format("Exception: %s", self:getCauseMessage())
end

--运行时异常
RuntimeException = class(Exception)

function RuntimeException:__init()
	self.cause = debug.getinfo(5, "Sl")
end

function RuntimeException:tostring()
	return string.format("RuntimeException: %s", self:getCauseMessage())
end

--assert判断条件不成立异常
AssertException = class(RuntimeException)

function RuntimeException:__init()
	self.cause = debug.getinfo(6, "Sl")
end

function AssertException:tostring()
	return string.format("AssertException: %s", self:getCauseMessage())
end
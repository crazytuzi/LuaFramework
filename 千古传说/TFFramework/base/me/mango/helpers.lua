--
-- Author: MiYu
-- Date: 2014-02-20 17:39:39
--

me = me or {}

me.isnull = tolua.isnull

me.notnull = function(...)
	return not me.isnull(...)
end
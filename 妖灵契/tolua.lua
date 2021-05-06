--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
-- if jit then		
-- 	if jit.opt then
-- 		jit.opt.start(3)			
-- 	end
-- 	print("jit", jit.status())
-- 	print(string.format("os: %s, arch: %s", jit.os, jit.arch))
-- end

-- if DebugServerIp then  
--   require("mobdebug").start(DebugServerIp)
-- end

local platform = UnityEngine.Application.platform
g_IsEditor = (platform == 0 or platform == 7)
if g_IsEditor then
	require "core.strict"
end
require "core.global"
require "core.string"
require "core.table"
require "core.class"
require "core.typeof"
require "core.protobuf"
require  "core.Math"
require "core.ZZBase64"

Mathf		= require "UnityEngine.Mathf"
Vector3 	= require "UnityEngine.Vector3"
Quaternion	= require "UnityEngine.Quaternion"
Vector2		= require "UnityEngine.Vector2"
Vector4		= require "UnityEngine.Vector4"
Color		= require "UnityEngine.Color"
Ray			= require "UnityEngine.Ray"
Bounds		= require "UnityEngine.Bounds"
RaycastHit	= require "UnityEngine.RaycastHit"
Touch		= require "UnityEngine.Touch"
LayerMask	= require "UnityEngine.LayerMask"
Plane		= require "UnityEngine.Plane"
Time		= reimport "UnityEngine.Time"
DOTween 	 = require "logic.DOTween"
list		= require "core.list"
utf8		= require "core.utf8"
MathBit		= require "core.MathBit"
cjson		= require "cjson"
cjson.encode_sparse_array(true)

require "core.event"
require "System.Timer"
require "System.coroutine"
require "System.ValueType"
require "System.Reflection.BindingFlags"
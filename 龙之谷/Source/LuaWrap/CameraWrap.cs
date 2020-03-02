using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class CameraWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("SetTargetBuffers", SetTargetBuffers),
			new LuaMethod("ResetWorldToCameraMatrix", ResetWorldToCameraMatrix),
			new LuaMethod("ResetProjectionMatrix", ResetProjectionMatrix),
			new LuaMethod("ResetAspect", ResetAspect),
			new LuaMethod("ResetFieldOfView", ResetFieldOfView),
			new LuaMethod("GetStereoViewMatrix", GetStereoViewMatrix),
			new LuaMethod("SetStereoViewMatrix", SetStereoViewMatrix),
			new LuaMethod("ResetStereoViewMatrices", ResetStereoViewMatrices),
			new LuaMethod("GetStereoProjectionMatrix", GetStereoProjectionMatrix),
			new LuaMethod("SetStereoProjectionMatrix", SetStereoProjectionMatrix),
			new LuaMethod("CalculateFrustumCorners", CalculateFrustumCorners),
			new LuaMethod("ResetStereoProjectionMatrices", ResetStereoProjectionMatrices),
			new LuaMethod("WorldToScreenPoint", WorldToScreenPoint),
			new LuaMethod("WorldToViewportPoint", WorldToViewportPoint),
			new LuaMethod("ViewportToWorldPoint", ViewportToWorldPoint),
			new LuaMethod("ScreenToWorldPoint", ScreenToWorldPoint),
			new LuaMethod("ScreenToViewportPoint", ScreenToViewportPoint),
			new LuaMethod("ViewportToScreenPoint", ViewportToScreenPoint),
			new LuaMethod("ViewportPointToRay", ViewportPointToRay),
			new LuaMethod("ScreenPointToRay", ScreenPointToRay),
			new LuaMethod("GetAllCameras", GetAllCameras),
			new LuaMethod("Render", Render),
			new LuaMethod("RenderWithShader", RenderWithShader),
			new LuaMethod("SetReplacementShader", SetReplacementShader),
			new LuaMethod("ResetReplacementShader", ResetReplacementShader),
			new LuaMethod("ResetCullingMatrix", ResetCullingMatrix),
			new LuaMethod("RenderDontRestore", RenderDontRestore),
			new LuaMethod("SetupCurrent", SetupCurrent),
			new LuaMethod("RenderToCubemap", RenderToCubemap),
			new LuaMethod("CopyFrom", CopyFrom),
			new LuaMethod("AddCommandBuffer", AddCommandBuffer),
			new LuaMethod("RemoveCommandBuffer", RemoveCommandBuffer),
			new LuaMethod("RemoveCommandBuffers", RemoveCommandBuffers),
			new LuaMethod("RemoveAllCommandBuffers", RemoveAllCommandBuffers),
			new LuaMethod("GetCommandBuffers", GetCommandBuffers),
			new LuaMethod("CalculateObliqueMatrix", CalculateObliqueMatrix),
			new LuaMethod("New", _CreateCamera),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("onPreCull", get_onPreCull, set_onPreCull),
			new LuaField("onPreRender", get_onPreRender, set_onPreRender),
			new LuaField("onPostRender", get_onPostRender, set_onPostRender),
			new LuaField("fieldOfView", get_fieldOfView, set_fieldOfView),
			new LuaField("nearClipPlane", get_nearClipPlane, set_nearClipPlane),
			new LuaField("farClipPlane", get_farClipPlane, set_farClipPlane),
			new LuaField("renderingPath", get_renderingPath, set_renderingPath),
			new LuaField("actualRenderingPath", get_actualRenderingPath, null),
			new LuaField("hdr", get_hdr, set_hdr),
			new LuaField("orthographicSize", get_orthographicSize, set_orthographicSize),
			new LuaField("orthographic", get_orthographic, set_orthographic),
			new LuaField("opaqueSortMode", get_opaqueSortMode, set_opaqueSortMode),
			new LuaField("transparencySortMode", get_transparencySortMode, set_transparencySortMode),
			new LuaField("depth", get_depth, set_depth),
			new LuaField("aspect", get_aspect, set_aspect),
			new LuaField("cullingMask", get_cullingMask, set_cullingMask),
			new LuaField("eventMask", get_eventMask, set_eventMask),
			new LuaField("backgroundColor", get_backgroundColor, set_backgroundColor),
			new LuaField("rect", get_rect, set_rect),
			new LuaField("pixelRect", get_pixelRect, set_pixelRect),
			new LuaField("targetTexture", get_targetTexture, set_targetTexture),
			new LuaField("pixelWidth", get_pixelWidth, null),
			new LuaField("pixelHeight", get_pixelHeight, null),
			new LuaField("cameraToWorldMatrix", get_cameraToWorldMatrix, null),
			new LuaField("worldToCameraMatrix", get_worldToCameraMatrix, set_worldToCameraMatrix),
			new LuaField("projectionMatrix", get_projectionMatrix, set_projectionMatrix),
			new LuaField("nonJitteredProjectionMatrix", get_nonJitteredProjectionMatrix, set_nonJitteredProjectionMatrix),
			new LuaField("useJitteredProjectionMatrixForTransparentRendering", get_useJitteredProjectionMatrixForTransparentRendering, set_useJitteredProjectionMatrixForTransparentRendering),
			new LuaField("velocity", get_velocity, null),
			new LuaField("clearFlags", get_clearFlags, set_clearFlags),
			new LuaField("stereoEnabled", get_stereoEnabled, null),
			new LuaField("stereoSeparation", get_stereoSeparation, set_stereoSeparation),
			new LuaField("stereoConvergence", get_stereoConvergence, set_stereoConvergence),
			new LuaField("cameraType", get_cameraType, set_cameraType),
			new LuaField("stereoMirrorMode", get_stereoMirrorMode, set_stereoMirrorMode),
			new LuaField("stereoTargetEye", get_stereoTargetEye, set_stereoTargetEye),
			new LuaField("stereoActiveEye", get_stereoActiveEye, null),
			new LuaField("targetDisplay", get_targetDisplay, set_targetDisplay),
			new LuaField("main", get_main, null),
			new LuaField("current", get_current, null),
			new LuaField("allCameras", get_allCameras, null),
			new LuaField("allCamerasCount", get_allCamerasCount, null),
			new LuaField("useOcclusionCulling", get_useOcclusionCulling, set_useOcclusionCulling),
			new LuaField("cullingMatrix", get_cullingMatrix, set_cullingMatrix),
			new LuaField("layerCullDistances", get_layerCullDistances, set_layerCullDistances),
			new LuaField("layerCullSpherical", get_layerCullSpherical, set_layerCullSpherical),
			new LuaField("depthTextureMode", get_depthTextureMode, set_depthTextureMode),
			new LuaField("clearStencilAfterLightingPass", get_clearStencilAfterLightingPass, set_clearStencilAfterLightingPass),
			new LuaField("commandBufferCount", get_commandBufferCount, null),
		};

		LuaScriptMgr.RegisterLib(L, "UnityEngine.Camera", typeof(Camera), regs, fields, typeof(Behaviour));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateCamera(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			Camera obj = new Camera();
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Camera.New");
		}

		return 0;
	}

	static Type classType = typeof(Camera);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPreCull(IntPtr L)
	{
		LuaScriptMgr.Push(L, Camera.onPreCull);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPreRender(IntPtr L)
	{
		LuaScriptMgr.Push(L, Camera.onPreRender);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPostRender(IntPtr L)
	{
		LuaScriptMgr.Push(L, Camera.onPostRender);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fieldOfView(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fieldOfView");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fieldOfView on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.fieldOfView);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_nearClipPlane(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name nearClipPlane");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index nearClipPlane on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.nearClipPlane);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_farClipPlane(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name farClipPlane");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index farClipPlane on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.farClipPlane);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_renderingPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name renderingPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index renderingPath on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.renderingPath);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_actualRenderingPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name actualRenderingPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index actualRenderingPath on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.actualRenderingPath);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hdr(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hdr");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hdr on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hdr);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_orthographicSize(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name orthographicSize");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index orthographicSize on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.orthographicSize);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_orthographic(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name orthographic");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index orthographic on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.orthographic);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_opaqueSortMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name opaqueSortMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index opaqueSortMode on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.opaqueSortMode);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_transparencySortMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name transparencySortMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index transparencySortMode on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.transparencySortMode);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_depth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name depth");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index depth on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.depth);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_aspect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name aspect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index aspect on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.aspect);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cullingMask(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cullingMask");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cullingMask on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.cullingMask);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_eventMask(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name eventMask");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index eventMask on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.eventMask);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_backgroundColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name backgroundColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index backgroundColor on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.backgroundColor);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name rect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index rect on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.rect);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pixelRect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pixelRect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pixelRect on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.pixelRect);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_targetTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name targetTexture");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index targetTexture on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.targetTexture);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pixelWidth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pixelWidth");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pixelWidth on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.pixelWidth);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pixelHeight(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pixelHeight");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pixelHeight on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.pixelHeight);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cameraToWorldMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cameraToWorldMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cameraToWorldMatrix on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.cameraToWorldMatrix);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_worldToCameraMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name worldToCameraMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index worldToCameraMatrix on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.worldToCameraMatrix);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_projectionMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name projectionMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index projectionMatrix on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.projectionMatrix);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_nonJitteredProjectionMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name nonJitteredProjectionMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index nonJitteredProjectionMatrix on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.nonJitteredProjectionMatrix);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_useJitteredProjectionMatrixForTransparentRendering(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name useJitteredProjectionMatrixForTransparentRendering");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index useJitteredProjectionMatrixForTransparentRendering on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.useJitteredProjectionMatrixForTransparentRendering);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_velocity(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name velocity");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index velocity on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.velocity);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_clearFlags(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name clearFlags");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index clearFlags on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.clearFlags);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_stereoEnabled(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoEnabled");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoEnabled on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.stereoEnabled);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_stereoSeparation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoSeparation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoSeparation on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.stereoSeparation);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_stereoConvergence(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoConvergence");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoConvergence on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.stereoConvergence);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cameraType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cameraType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cameraType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.cameraType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_stereoMirrorMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoMirrorMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoMirrorMode on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.stereoMirrorMode);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_stereoTargetEye(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoTargetEye");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoTargetEye on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.stereoTargetEye);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_stereoActiveEye(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoActiveEye");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoActiveEye on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.stereoActiveEye);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_targetDisplay(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name targetDisplay");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index targetDisplay on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.targetDisplay);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_main(IntPtr L)
	{
		LuaScriptMgr.Push(L, Camera.main);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_current(IntPtr L)
	{
		LuaScriptMgr.Push(L, Camera.current);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_allCameras(IntPtr L)
	{
		LuaScriptMgr.PushArray(L, Camera.allCameras);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_allCamerasCount(IntPtr L)
	{
		LuaScriptMgr.Push(L, Camera.allCamerasCount);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_useOcclusionCulling(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name useOcclusionCulling");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index useOcclusionCulling on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.useOcclusionCulling);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cullingMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cullingMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cullingMatrix on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.cullingMatrix);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_layerCullDistances(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name layerCullDistances");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index layerCullDistances on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.layerCullDistances);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_layerCullSpherical(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name layerCullSpherical");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index layerCullSpherical on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.layerCullSpherical);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_depthTextureMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name depthTextureMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index depthTextureMode on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.depthTextureMode);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_clearStencilAfterLightingPass(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name clearStencilAfterLightingPass");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index clearStencilAfterLightingPass on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.clearStencilAfterLightingPass);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_commandBufferCount(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name commandBufferCount");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index commandBufferCount on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.commandBufferCount);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPreCull(IntPtr L)
	{
		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			Camera.onPreCull = (Camera.CameraCallback)LuaScriptMgr.GetNetObject(L, 3, typeof(Camera.CameraCallback));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			Camera.onPreCull = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPreRender(IntPtr L)
	{
		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			Camera.onPreRender = (Camera.CameraCallback)LuaScriptMgr.GetNetObject(L, 3, typeof(Camera.CameraCallback));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			Camera.onPreRender = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPostRender(IntPtr L)
	{
		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			Camera.onPostRender = (Camera.CameraCallback)LuaScriptMgr.GetNetObject(L, 3, typeof(Camera.CameraCallback));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			Camera.onPostRender = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fieldOfView(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fieldOfView");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fieldOfView on a nil value");
			}
		}

		obj.fieldOfView = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_nearClipPlane(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name nearClipPlane");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index nearClipPlane on a nil value");
			}
		}

		obj.nearClipPlane = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_farClipPlane(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name farClipPlane");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index farClipPlane on a nil value");
			}
		}

		obj.farClipPlane = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_renderingPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name renderingPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index renderingPath on a nil value");
			}
		}

		obj.renderingPath = (RenderingPath)LuaScriptMgr.GetNetObject(L, 3, typeof(RenderingPath));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_hdr(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hdr");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hdr on a nil value");
			}
		}

		obj.hdr = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_orthographicSize(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name orthographicSize");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index orthographicSize on a nil value");
			}
		}

		obj.orthographicSize = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_orthographic(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name orthographic");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index orthographic on a nil value");
			}
		}

		obj.orthographic = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_opaqueSortMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name opaqueSortMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index opaqueSortMode on a nil value");
			}
		}

		obj.opaqueSortMode = (UnityEngine.Rendering.OpaqueSortMode)LuaScriptMgr.GetNetObject(L, 3, typeof(UnityEngine.Rendering.OpaqueSortMode));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_transparencySortMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name transparencySortMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index transparencySortMode on a nil value");
			}
		}

		obj.transparencySortMode = (TransparencySortMode)LuaScriptMgr.GetNetObject(L, 3, typeof(TransparencySortMode));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_depth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name depth");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index depth on a nil value");
			}
		}

		obj.depth = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_aspect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name aspect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index aspect on a nil value");
			}
		}

		obj.aspect = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cullingMask(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cullingMask");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cullingMask on a nil value");
			}
		}

		obj.cullingMask = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_eventMask(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name eventMask");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index eventMask on a nil value");
			}
		}

		obj.eventMask = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_backgroundColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name backgroundColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index backgroundColor on a nil value");
			}
		}

		obj.backgroundColor = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name rect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index rect on a nil value");
			}
		}

		obj.rect = (Rect)LuaScriptMgr.GetNetObject(L, 3, typeof(Rect));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pixelRect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pixelRect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pixelRect on a nil value");
			}
		}

		obj.pixelRect = (Rect)LuaScriptMgr.GetNetObject(L, 3, typeof(Rect));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_targetTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name targetTexture");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index targetTexture on a nil value");
			}
		}

		obj.targetTexture = (RenderTexture)LuaScriptMgr.GetUnityObject(L, 3, typeof(RenderTexture));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_worldToCameraMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name worldToCameraMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index worldToCameraMatrix on a nil value");
			}
		}

		obj.worldToCameraMatrix = (Matrix4x4)LuaScriptMgr.GetNetObject(L, 3, typeof(Matrix4x4));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_projectionMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name projectionMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index projectionMatrix on a nil value");
			}
		}

		obj.projectionMatrix = (Matrix4x4)LuaScriptMgr.GetNetObject(L, 3, typeof(Matrix4x4));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_nonJitteredProjectionMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name nonJitteredProjectionMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index nonJitteredProjectionMatrix on a nil value");
			}
		}

		obj.nonJitteredProjectionMatrix = (Matrix4x4)LuaScriptMgr.GetNetObject(L, 3, typeof(Matrix4x4));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_useJitteredProjectionMatrixForTransparentRendering(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name useJitteredProjectionMatrixForTransparentRendering");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index useJitteredProjectionMatrixForTransparentRendering on a nil value");
			}
		}

		obj.useJitteredProjectionMatrixForTransparentRendering = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_clearFlags(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name clearFlags");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index clearFlags on a nil value");
			}
		}

		obj.clearFlags = (CameraClearFlags)LuaScriptMgr.GetNetObject(L, 3, typeof(CameraClearFlags));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_stereoSeparation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoSeparation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoSeparation on a nil value");
			}
		}

		obj.stereoSeparation = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_stereoConvergence(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoConvergence");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoConvergence on a nil value");
			}
		}

		obj.stereoConvergence = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cameraType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cameraType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cameraType on a nil value");
			}
		}

		obj.cameraType = (CameraType)LuaScriptMgr.GetNetObject(L, 3, typeof(CameraType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_stereoMirrorMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoMirrorMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoMirrorMode on a nil value");
			}
		}

		obj.stereoMirrorMode = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_stereoTargetEye(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name stereoTargetEye");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index stereoTargetEye on a nil value");
			}
		}

		obj.stereoTargetEye = (StereoTargetEyeMask)LuaScriptMgr.GetNetObject(L, 3, typeof(StereoTargetEyeMask));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_targetDisplay(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name targetDisplay");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index targetDisplay on a nil value");
			}
		}

		obj.targetDisplay = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_useOcclusionCulling(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name useOcclusionCulling");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index useOcclusionCulling on a nil value");
			}
		}

		obj.useOcclusionCulling = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cullingMatrix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cullingMatrix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cullingMatrix on a nil value");
			}
		}

		obj.cullingMatrix = (Matrix4x4)LuaScriptMgr.GetNetObject(L, 3, typeof(Matrix4x4));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_layerCullDistances(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name layerCullDistances");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index layerCullDistances on a nil value");
			}
		}

		obj.layerCullDistances = LuaScriptMgr.GetArrayNumber<float>(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_layerCullSpherical(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name layerCullSpherical");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index layerCullSpherical on a nil value");
			}
		}

		obj.layerCullSpherical = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_depthTextureMode(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name depthTextureMode");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index depthTextureMode on a nil value");
			}
		}

		obj.depthTextureMode = (DepthTextureMode)LuaScriptMgr.GetNetObject(L, 3, typeof(DepthTextureMode));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_clearStencilAfterLightingPass(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		Camera obj = (Camera)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name clearStencilAfterLightingPass");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index clearStencilAfterLightingPass on a nil value");
			}
		}

		obj.clearStencilAfterLightingPass = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTargetBuffers(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(RenderBuffer[]), typeof(RenderBuffer)))
		{
			Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
			RenderBuffer[] objs0 = LuaScriptMgr.GetArrayObject<RenderBuffer>(L, 2);
			RenderBuffer arg1 = (RenderBuffer)LuaScriptMgr.GetLuaObject(L, 3);
			obj.SetTargetBuffers(objs0,arg1);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(RenderBuffer), typeof(RenderBuffer)))
		{
			Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
			RenderBuffer arg0 = (RenderBuffer)LuaScriptMgr.GetLuaObject(L, 2);
			RenderBuffer arg1 = (RenderBuffer)LuaScriptMgr.GetLuaObject(L, 3);
			obj.SetTargetBuffers(arg0,arg1);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Camera.SetTargetBuffers");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetWorldToCameraMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetWorldToCameraMatrix();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetProjectionMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetProjectionMatrix();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetAspect(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetAspect();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetFieldOfView(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetFieldOfView();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetStereoViewMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Camera.StereoscopicEye arg0 = (Camera.StereoscopicEye)LuaScriptMgr.GetNetObject(L, 2, typeof(Camera.StereoscopicEye));
		Matrix4x4 o = obj.GetStereoViewMatrix(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetStereoViewMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Camera.StereoscopicEye arg0 = (Camera.StereoscopicEye)LuaScriptMgr.GetNetObject(L, 2, typeof(Camera.StereoscopicEye));
		Matrix4x4 arg1 = (Matrix4x4)LuaScriptMgr.GetNetObject(L, 3, typeof(Matrix4x4));
		obj.SetStereoViewMatrix(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetStereoViewMatrices(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetStereoViewMatrices();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetStereoProjectionMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Camera.StereoscopicEye arg0 = (Camera.StereoscopicEye)LuaScriptMgr.GetNetObject(L, 2, typeof(Camera.StereoscopicEye));
		Matrix4x4 o = obj.GetStereoProjectionMatrix(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetStereoProjectionMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Camera.StereoscopicEye arg0 = (Camera.StereoscopicEye)LuaScriptMgr.GetNetObject(L, 2, typeof(Camera.StereoscopicEye));
		Matrix4x4 arg1 = (Matrix4x4)LuaScriptMgr.GetNetObject(L, 3, typeof(Matrix4x4));
		obj.SetStereoProjectionMatrix(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculateFrustumCorners(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 5);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Rect arg0 = (Rect)LuaScriptMgr.GetNetObject(L, 2, typeof(Rect));
		float arg1 = (float)LuaScriptMgr.GetNumber(L, 3);
		Camera.MonoOrStereoscopicEye arg2 = (Camera.MonoOrStereoscopicEye)LuaScriptMgr.GetNetObject(L, 4, typeof(Camera.MonoOrStereoscopicEye));
		Vector3[] objs3 = LuaScriptMgr.GetArrayObject<Vector3>(L, 5);
		obj.CalculateFrustumCorners(arg0,arg1,arg2,objs3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetStereoProjectionMatrices(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetStereoProjectionMatrices();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WorldToScreenPoint(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Vector3 o = obj.WorldToScreenPoint(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WorldToViewportPoint(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Vector3 o = obj.WorldToViewportPoint(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ViewportToWorldPoint(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Vector3 o = obj.ViewportToWorldPoint(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ScreenToWorldPoint(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Vector3 o = obj.ScreenToWorldPoint(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ScreenToViewportPoint(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Vector3 o = obj.ScreenToViewportPoint(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ViewportToScreenPoint(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Vector3 o = obj.ViewportToScreenPoint(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ViewportPointToRay(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Ray o = obj.ViewportPointToRay(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ScreenPointToRay(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		Ray o = obj.ScreenPointToRay(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetAllCameras(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera[] objs0 = LuaScriptMgr.GetArrayObject<Camera>(L, 1);
		int o = Camera.GetAllCameras(objs0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Render(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.Render();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RenderWithShader(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Shader arg0 = (Shader)LuaScriptMgr.GetUnityObject(L, 2, typeof(Shader));
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		obj.RenderWithShader(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetReplacementShader(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Shader arg0 = (Shader)LuaScriptMgr.GetUnityObject(L, 2, typeof(Shader));
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		obj.SetReplacementShader(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetReplacementShader(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetReplacementShader();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetCullingMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.ResetCullingMatrix();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RenderDontRestore(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.RenderDontRestore();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetupCurrent(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera arg0 = (Camera)LuaScriptMgr.GetUnityObject(L, 1, typeof(Camera));
		Camera.SetupCurrent(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RenderToCubemap(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(RenderTexture)))
		{
			Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
			RenderTexture arg0 = (RenderTexture)LuaScriptMgr.GetLuaObject(L, 2);
			bool o = obj.RenderToCubemap(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(Cubemap)))
		{
			Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
			Cubemap arg0 = (Cubemap)LuaScriptMgr.GetLuaObject(L, 2);
			bool o = obj.RenderToCubemap(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(RenderTexture), typeof(int)))
		{
			Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
			RenderTexture arg0 = (RenderTexture)LuaScriptMgr.GetLuaObject(L, 2);
			int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
			bool o = obj.RenderToCubemap(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(Cubemap), typeof(int)))
		{
			Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
			Cubemap arg0 = (Cubemap)LuaScriptMgr.GetLuaObject(L, 2);
			int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
			bool o = obj.RenderToCubemap(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Camera.RenderToCubemap");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CopyFrom(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Camera arg0 = (Camera)LuaScriptMgr.GetUnityObject(L, 2, typeof(Camera));
		obj.CopyFrom(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddCommandBuffer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		UnityEngine.Rendering.CameraEvent arg0 = (UnityEngine.Rendering.CameraEvent)LuaScriptMgr.GetNetObject(L, 2, typeof(UnityEngine.Rendering.CameraEvent));
		UnityEngine.Rendering.CommandBuffer arg1 = (UnityEngine.Rendering.CommandBuffer)LuaScriptMgr.GetNetObject(L, 3, typeof(UnityEngine.Rendering.CommandBuffer));
		obj.AddCommandBuffer(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveCommandBuffer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		UnityEngine.Rendering.CameraEvent arg0 = (UnityEngine.Rendering.CameraEvent)LuaScriptMgr.GetNetObject(L, 2, typeof(UnityEngine.Rendering.CameraEvent));
		UnityEngine.Rendering.CommandBuffer arg1 = (UnityEngine.Rendering.CommandBuffer)LuaScriptMgr.GetNetObject(L, 3, typeof(UnityEngine.Rendering.CommandBuffer));
		obj.RemoveCommandBuffer(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveCommandBuffers(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		UnityEngine.Rendering.CameraEvent arg0 = (UnityEngine.Rendering.CameraEvent)LuaScriptMgr.GetNetObject(L, 2, typeof(UnityEngine.Rendering.CameraEvent));
		obj.RemoveCommandBuffers(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveAllCommandBuffers(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		obj.RemoveAllCommandBuffers();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCommandBuffers(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		UnityEngine.Rendering.CameraEvent arg0 = (UnityEngine.Rendering.CameraEvent)LuaScriptMgr.GetNetObject(L, 2, typeof(UnityEngine.Rendering.CameraEvent));
		UnityEngine.Rendering.CommandBuffer[] o = obj.GetCommandBuffers(arg0);
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculateObliqueMatrix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Camera obj = (Camera)LuaScriptMgr.GetUnityObjectSelf(L, 1, "Camera");
		Vector4 arg0 = LuaScriptMgr.GetVector4(L, 2);
		Matrix4x4 o = obj.CalculateObliqueMatrix(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Lua_Eq(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Object arg0 = LuaScriptMgr.GetLuaObject(L, 1) as Object;
		Object arg1 = LuaScriptMgr.GetLuaObject(L, 2) as Object;
		bool o = arg0 == arg1;
		LuaScriptMgr.Push(L, o);
		return 1;
	}
}


<?xml version="1.0" encoding="UTF-8"?>

<Project Name="LUA.luaprj" >
    <Filter Name="System" >
        <LuaFile RelativePath=".\System\Bounds.lua" />
        <LuaFile RelativePath=".\System\class.lua" />
        <LuaFile RelativePath=".\System\Color.lua" />
        <LuaFile RelativePath=".\System\Coroutine.lua" />
        <LuaFile RelativePath=".\System\Event.lua" />
        <LuaFile RelativePath=".\System\Global.lua" />
        <LuaFile RelativePath=".\System\Layer.lua" />
        <LuaFile RelativePath=".\System\List.lua" />
        <LuaFile RelativePath=".\System\Main.lua" />
        <LuaFile RelativePath=".\System\Math.lua" />
        <LuaFile RelativePath=".\System\Plane.lua" />
        <LuaFile RelativePath=".\System\Quaternion.lua" />
        <LuaFile RelativePath=".\System\Ray.lua" />
        <LuaFile RelativePath=".\System\Raycast.lua" />
        <LuaFile RelativePath=".\System\Set.lua" />
        <LuaFile RelativePath=".\System\strict.lua" />
        <LuaFile RelativePath=".\System\Test.lua" />
        <LuaFile RelativePath=".\System\Time.lua" />
        <LuaFile RelativePath=".\System\Timer.lua" />
        <LuaFile RelativePath=".\System\Touch.lua" />
        <LuaFile RelativePath=".\System\Vector2.lua" />
        <LuaFile RelativePath=".\System\Vector3.lua" />
        <LuaFile RelativePath=".\System\Vector4.lua" />
        <LuaFile RelativePath=".\System\Wrap.lua" />
    </Filter>
    <Filter Name="Core" >
        <LuaFile RelativePath=".\Core\Engine.lua" />
        <Filter Name="Manager" >
            <LuaFile RelativePath=".\Core\Manager\MessageManager.lua" />
            <LuaFile RelativePath=".\Core\Manager\ModuleManager.lua" />
            <LuaFile RelativePath=".\Core\Manager\PanelManager.lua" />
            <LuaFile RelativePath=".\Core\Manager\PingManager.lua" />
            <LuaFile RelativePath=".\Core\Manager\ProtocolManager.lua" />
        </Filter>
        <Filter Name="Module" >
            <Filter Name="Common" >
                <LuaFile RelativePath=".\Core\Module\Common\Alert.lua" />
                <LuaFile RelativePath=".\Core\Module\Common\EaseUtil.lua" />
                <LuaFile RelativePath=".\Core\Module\Common\Panel.lua" />
                <LuaFile RelativePath=".\Core\Module\Common\ResID.lua" />
                <LuaFile RelativePath=".\Core\Module\Common\UIComponent.lua" />
                <LuaFile RelativePath=".\Core\Module\Common\UIPanel.lua" />
            </Filter>
            <Filter Name="Demo" >
                <LuaFile RelativePath=".\Core\Module\Demo\DemoMediator.lua" />
                <LuaFile RelativePath=".\Core\Module\Demo\DemoModule.lua" />
                <LuaFile RelativePath=".\Core\Module\Demo\DemoNotes.lua" />
                <LuaFile RelativePath=".\Core\Module\Demo\DemoProxy.lua" />
                <Filter Name="View" >
                    <LuaFile RelativePath=".\Core\Module\Demo\View\DemoPanel.lua" />
                </Filter>
            </Filter>
            <Filter Name="Pattern" >
                <LuaFile RelativePath=".\Core\Module\Pattern\BaseModule.lua" />
                <LuaFile RelativePath=".\Core\Module\Pattern\Command.lua" />
                <LuaFile RelativePath=".\Core\Module\Pattern\Mediator.lua" />
                <LuaFile RelativePath=".\Core\Module\Pattern\Notification.lua" />
                <LuaFile RelativePath=".\Core\Module\Pattern\Notifier.lua" />
                <LuaFile RelativePath=".\Core\Module\Pattern\Proxy.lua" />
            </Filter>
        </Filter>
        <Filter Name="Net" >
            <LuaFile RelativePath=".\Core\Net\Pt10.lua" />
            <LuaFile RelativePath=".\Core\Net\PtCommand.lua" />
            <LuaFile RelativePath=".\Core\Net\PtRegister.lua" />
            <LuaFile RelativePath=".\Core\Net\PtType.lua" />
            <LuaFile RelativePath=".\Core\Net\SenderWatcher.lua" />
            <LuaFile RelativePath=".\Core\Net\SimpleSender.lua" />
            <LuaFile RelativePath=".\Core\Net\SocketWatcher.lua" />
            <LuaFile RelativePath=".\Core\Net\PtBuffer.lua" />
        </Filter>
    </Filter>
    <Filter Name="Common" >
        <LuaFile RelativePath=".\Common\define.lua" />
        <LuaFile RelativePath=".\Common\functions.lua" />
    </Filter>
</Project>
--
-- Testmodule initialisation, this script is called via autoload mechanism when the
-- TeamSpeak 3 client starts.
--

require("ts3init")            -- Required for ts3RegisterModule
require("TauntBot/events")  -- Forwarded TeamSpeak 3 callbacks
--require("testmodule/demo")    -- Some demo functions callable from TS3 client chat input

local MODULE_NAME = "TauntBot"

-- Define which callbacks you want to receive in your module. Callbacks not mentioned
-- here will not be called. To avoid function name collisions, your callbacks should
-- be put into an own package.
local registeredEvents = {
	createMenus = createMenus,
	onConnectStatusChangeEvent = testmodule_events.onConnectStatusChangeEvent,
	onNewChannelEvent = testmodule_events.onNewChannelEvent,
	onTalkStatusChangeEvent = testmodule_events.onTalkStatusChangeEvent,
	onTextMessageEvent = testmodule_events.onTextMessageEvent,
	onPluginCommandEvent = testmodule_events.onPluginCommandEvent,
	onMenuItemEvent = testmodule_events.onMenuItemEvent
}

-- Register your callback functions with a unique module name.
ts3RegisterModule(MODULE_NAME, registeredEvents)

-- Paste files from system clipboard into current directory
-- Handles both image data (screenshots) and files copied with cb

local get_current_dir = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

return {
	entry = function()
		local cwd = get_current_dir()

		-- Use the paste-cb helper script
		local child, err = Command("paste-cb")
			:arg(cwd)
			:stdout(Command.PIPED)
			:stderr(Command.PIPED)
			:spawn()

		if not child then
			ya.notify({
				title = "System Clipboard",
				content = string.format("Failed to spawn: %s", tostring(err)),
				level = "error",
				timeout = 5,
			})
			return
		end

		local output, err = child:wait_with_output()

		if output and output.status.success then
			local stdout = output.stdout and #output.stdout > 0 and output.stdout or "Successfully pasted from clipboard"
			ya.notify({
				title = "System Clipboard",
				content = stdout,
				level = "info",
				timeout = 5,
			})
		else
			local stderr = output and output.stderr or tostring(err)
			ya.notify({
				title = "System Clipboard",
				content = stderr and #stderr > 0 and stderr or "No files or images found in clipboard",
				level = "warn",
				timeout = 5,
			})
		end
	end,
}

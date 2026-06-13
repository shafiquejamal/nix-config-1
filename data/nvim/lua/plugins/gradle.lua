-- Gradle integration via simple terminal commands.
-- Keymaps are registered only when a Gradle wrapper is present in the project.
return {
	"nvim-lua/plenary.nvim", -- already a transitive dep; listed here to hang config on
	lazy = true,
	config = function() end,
	init = function()
		-- Only register Gradle keymaps when a gradlew wrapper exists upward.
		local roots = vim.fs.find({ "gradlew", "gradlew.bat" }, { upward = true, limit = 1 })
		if #roots == 0 then return end

		local gradlew = roots[1]

		local function gradle(task)
			return function()
				-- Use a floating terminal via snacks if available, otherwise :term
				local ok, snacks = pcall(require, "snacks")
				if ok and snacks.terminal then
					snacks.terminal.open(gradlew .. " " .. task, { cwd = vim.fn.fnamemodify(gradlew, ":h") })
				else
					vim.cmd("split | terminal " .. gradlew .. " " .. task)
				end
			end
		end

		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
		end

		map("<leader>gb", gradle("build"), "[G]radle [B]uild")
		map("<leader>gc", gradle("clean"), "[G]radle [C]lean")
		map("<leader>gT", gradle("test"), "[G]radle [T]est")
		map("<leader>gr", gradle("run"), "[G]radle [R]un")
		map("<leader>grc", gradle("runClient"), "[G]radle [R]un[C]lient")
		map("<leader>grs", gradle("runServer"), "[G]radle [R]un[S]erver")
		map("<leader>gd", gradle("dependencies"), "[G]radle [D]ependencies")
	end,
}

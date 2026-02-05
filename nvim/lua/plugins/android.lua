-- Android Development Setup for Neovim
-- This file configures everything needed for Android development: LSP, DAP, Gradle tasks, ADB commands, etc.

return {
  -- Import LazyVim's Java extra which includes nvim-jdtls configuration
  {
    "LazyVim/LazyVim",
    opts = {
      -- This will be automatically merged with lazyvim.json
    },
  },

  -- Enhanced Java/Kotlin support with nvim-jdtls
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java", "kotlin" },
    opts = function()
      return {
        -- Root directory detection for Android projects
        root_dir = function(fname)
          local util = require("jdtls.setup")
          return util.find_root({
            "gradlew",
            "build.gradle",
            "build.gradle.kts",
            "settings.gradle",
            "settings.gradle.kts",
            ".git",
          }, fname)
        end,

        -- Java settings
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = {
              favoriteStaticMembers = {
                "org.junit.Assert.*",
                "org.junit.Assume.*",
                "org.junit.jupiter.api.Assertions.*",
                "org.junit.jupiter.api.Assumptions.*",
                "org.mockito.Mockito.*",
                "org.mockito.ArgumentMatchers.*",
              },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              useBlocks = true,
            },
          },
        },

        -- Init options
        init_options = {
          bundles = {},
        },
      }
    end,
  },

  -- Kotlin language server support
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = {
          settings = {
            kotlin = {
              compiler = {
                jvm = {
                  target = "1.8", -- Android typically uses Java 8
                },
              },
            },
          },
        },
      },
    },
  },

  -- Gradle integration - Build tool commands
  {
    "nvim-lua/plenary.nvim",
    keys = {
      -- RUN: Build, Install & Launch (like Android Studio)
      {
        "<leader>Ar",
        function()
          -- Get package name from build.gradle
          local function get_package_name()
            local handle = io.popen(
              "grep -r 'applicationId' app/build.gradle* 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\"'"
            )
            if handle then
              local result = handle:read("*a")
              handle:close()
              return result:gsub("%s+", "")
            end
            return nil
          end

          -- Get launcher activity from AndroidManifest.xml
          local function get_launcher_activity()
            local handle = io.popen(
              "grep -B 5 'android.intent.action.MAIN' app/src/main/AndroidManifest.xml 2>/dev/null | grep 'android:name' | head -1 | sed 's/.*android:name=\"\\(.*\\)\".*/\\1/'"
            )
            if handle then
              local result = handle:read("*a")
              handle:close()
              return result:gsub("%s+", "")
            end
            return nil
          end

          local package = get_package_name()
          local activity = get_launcher_activity()

          if package and package ~= "" and activity and activity ~= "" then
            -- If activity starts with ".", it's relative to package
            if activity:sub(1, 1) == "." then
              activity = package .. activity
            end

            -- Build, install and launch
            local cmd = string.format("./gradlew installDebug && adb shell am start -n %s/%s", package, activity)
            vim.cmd("terminal " .. cmd)
          else
            -- Fallback: just install without launching
            vim.notify("Could not detect package/activity. Installing only...", vim.log.levels.WARN)
            vim.cmd("terminal ./gradlew installDebug")
          end
        end,
        desc = "Android: RUN (Install & Launch)",
      },

      -- Build commands
      {
        "<leader>Ab",
        function()
          vim.cmd("terminal ./gradlew assembleDebug")
        end,
        desc = "Android: Build Debug",
      },
      {
        "<leader>Ai",
        function()
          vim.cmd("terminal ./gradlew installDebug")
        end,
        desc = "Android: Install Only",
      },
      {
        "<leader>AR",
        function()
          vim.cmd("terminal ./gradlew assembleRelease")
        end,
        desc = "Android: Build Release",
      },
      {
        "<leader>Ac",
        function()
          vim.cmd("terminal ./gradlew clean")
        end,
        desc = "Android: Clean",
      },

      -- ADB commands
      {
        "<leader>Ad",
        "<cmd>terminal adb devices<cr>",
        desc = "Android: List Devices",
      },
      {
        "<leader>Al",
        function()
          vim.cmd("terminal adb logcat")
        end,
        desc = "Android: Logcat",
      },
      {
        "<leader>AL",
        function()
          vim.cmd("terminal adb logcat *:E")
        end,
        desc = "Android: Logcat (Errors only)",
      },
      {
        "<leader>As",
        "<cmd>terminal adb shell<cr>",
        desc = "Android: ADB Shell",
      },
      {
        "<leader>Ak",
        function()
          -- Kill app
          local handle =
            io.popen("grep -r 'applicationId' app/build.gradle* 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\"'")
          if handle then
            local package = handle:read("*a"):gsub("%s+", "")
            handle:close()
            if package and package ~= "" then
              vim.cmd("terminal adb shell am force-stop " .. package)
            end
          end
        end,
        desc = "Android: Kill App",
      },

      -- Wireless ADB commands
      {
        "<leader>Aw",
        function()
          vim.ui.input({ prompt = "Enter device IP (e.g., 192.168.1.100): " }, function(ip)
            if ip and ip ~= "" then
              vim.ui.input({ prompt = "Enter port (default 5555): " }, function(port)
                port = port and port ~= "" and port or "5555"
                local address = ip .. ":" .. port
                vim.cmd("terminal adb connect " .. address)
                vim.notify("Connecting to " .. address, vim.log.levels.INFO)
              end)
            end
          end)
        end,
        desc = "Android: Connect Wireless",
      },
      {
        "<leader>AW",
        function()
          vim.cmd("terminal adb disconnect")
          vim.notify("Disconnected all wireless devices", vim.log.levels.INFO)
        end,
        desc = "Android: Disconnect Wireless",
      },
      {
        "<leader>Ae",
        function()
          -- Enable wireless mode (device must be connected via USB first)
          vim.ui.input({ prompt = "Enter port (default 5555): " }, function(port)
            port = port and port ~= "" and port or "5555"
            vim.cmd("terminal adb tcpip " .. port)
            vim.notify(
              "Wireless ADB enabled on port " .. port .. ". Get device IP and use <leader>Aw to connect.",
              vim.log.levels.INFO
            )
          end)
        end,
        desc = "Android: Enable Wireless Mode",
      },
    },
  },

  -- DAP (Debug Adapter Protocol) for Android debugging
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "java-debug-adapter", "java-test" })
        end,
      },
    },
    opts = function()
      local dap = require("dap")

      -- Java/Kotlin debugging configuration
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
  },

  -- Add which-key group for Android commands
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>A", group = "android", icon = "󰀲" },
      },
    },
  },
}

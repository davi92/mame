function mainProject(_target, _subtarget)
	if (_target == _subtarget) then
		project (_target)
	else
		project (_target .. _subtarget)
	end	
	uuid (os.uuid(_target .."_" .. _subtarget))
	kind "ConsoleApp"

	options {
		"ForceCPP",
	}
	flags {
		"NoManifest",
	}

	if _OPTIONS["SYMBOLS"] then
		configuration { "mingw*" }
			postbuildcommands {
				"$(SILENT) echo Dumping symbols.",
				"$(SILENT) objdump --section=.text --line-numbers --syms --demangle $(TARGET) >$(subst .exe,.sym,$(TARGET))"
			}
	end
	
	configuration { "vs*" }
	flags {
		"Unicode",
	}
	configuration { "mingw*" or "vs*" }
		targetextension ".exe"

	configuration { "asmjs" }
		targetextension ".bc"  

	configuration { }
		targetdir(MAME_DIR)

	findfunction("linkProjects_" .. _OPTIONS["target"] .. "_" .. _OPTIONS["subtarget"])(_OPTIONS["target"], _OPTIONS["subtarget"])
	links {
		"osd_" .. _OPTIONS["osd"],
		"bus",
		"optional",
		"emu",
		"dasm",
		"utils",
		"expat",
		"softfloat",
		"jpeg",
		"flac",
		"7z",
		"formats",
		"lua",
		"lsqlite3",
		"sqllite3",
		"zlib",
		"jsoncpp",
		"mongoose",
		"portmidi",
	}
	if (USE_BGFX == 1) then
		links {
			"bgfx"
		}
	end
	links{
		"ocore_" .. _OPTIONS["osd"],
	}
	maintargetosdoptions(_target)

	includedirs {
		MAME_DIR .. "src/osd",
		MAME_DIR .. "src/emu",
		MAME_DIR .. "src/" .. _target,
		MAME_DIR .. "src/lib",
		MAME_DIR .. "src/lib/util",
		MAME_DIR .. "3rdparty",
		MAME_DIR .. "3rdparty/zlib",
		GEN_DIR  .. _target .. "/layout",
		GEN_DIR  .. "resource",
	}

	if _OPTIONS["targetos"]=="macosx" then
		linkoptions {
			"-sectcreate __TEXT __info_plist " .. GEN_DIR .. "/resource/" .. _OPTIONS["target"] .. "-Info.plist"
		}
	end

	if _OPTIONS["targetos"]=="windows" then
	end

	files {
		MAME_DIR .. "src/".._target .."/" .. _target ..".c",
		MAME_DIR .. "src/version.c",
		GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.c",
	}

	custombuildtask {
		{ MAME_DIR .. "src/".._target .."/" .. _subtarget ..".lst" ,  GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.c",    {  MAME_DIR .. "src/build/makelist.py" }, {"@echo Building driver list...",    "python $(1) $(<) > $(@)" }},
	}
	
	configuration { "mingw*" }
		custombuildtask {	
			{ MAME_DIR .. "src/version.c" ,  GEN_DIR  .. "/resource/" .. _target .. "vers.rc",    {  MAME_DIR .. "src/build/verinfo.py" }, {"@echo Emitting " .. _target .. "vers.rc" .. "...",    "python $(1)  -r -b " .. _target .. " $(<) > $(@)" }},
		}	
	
	configuration { "vs*" }
		prebuildcommands {	
			"mkdir " .. path.translate(GEN_DIR  .. "/resource/","\\") .. " 2>NUL",
			"@echo Emitting ".. _target .. "vers.rc...",
			"python " .. path.translate(MAME_DIR .. "src/build/verinfo.py","\\") .. " -r -b " .. _target .. " " .. path.translate(MAME_DIR .. "src/version.c","\\") .. " > " .. path.translate(GEN_DIR  .. "/resource/" .. _target .. "vers.rc", "\\") ,
		}	
	
	 
	configuration { }

	debugdir (MAME_DIR)
	debugargs ("-window")
end

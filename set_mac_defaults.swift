#!/usr/bin/env swift
// Set default macOS applications by file extension.
//
// Uses NSWorkspace.setDefaultApplication which correctly resolves UTIs,
// unlike direct plist manipulation which can be overridden by UTI-based entries.
//
// Dotfiles (.bashrc, .gitconfig) can't be handled — macOS treats them as
// extensionless (public.data) and protects that handler.
//
// Usage: swift set_mac_defaults.swift
//    or: chmod +x set_mac_defaults.swift && ./set_mac_defaults.swift

import AppKit
import UniformTypeIdentifiers

struct Default {
    let bundleID: String
    let ext: String
}

// Find bundle IDs: osascript -e 'id of app "App Name"'
let defaults: [Default] = [
    // Markdown
    .init(bundleID: "app.cyan.markedit", ext: "md"),

    // Text / configs
    .init(bundleID: "com.sublimetext.4", ext: "txt"),
    .init(bundleID: "com.sublimetext.4", ext: "json"),
    .init(bundleID: "com.sublimetext.4", ext: "xml"),
    .init(bundleID: "com.sublimetext.4", ext: "yaml"),
    .init(bundleID: "com.sublimetext.4", ext: "yml"),
    .init(bundleID: "com.sublimetext.4", ext: "toml"),
    .init(bundleID: "com.sublimetext.4", ext: "ini"),
    .init(bundleID: "com.sublimetext.4", ext: "conf"),
    .init(bundleID: "com.sublimetext.4", ext: "cfg"),
    .init(bundleID: "com.sublimetext.4", ext: "example"),

    // Text / data
    .init(bundleID: "com.sublimetext.4", ext: "csv"),
    .init(bundleID: "com.sublimetext.4", ext: "tsv"),
    .init(bundleID: "com.sublimetext.4", ext: "log"),

    // Text / IO files for programming contests
    // .init(bundleID: "com.sublimetext.4", ext: "in"),
    // .init(bundleID: "com.sublimetext.4", ext: "out"),
    // .init(bundleID: "com.sublimetext.4", ext: "ans"),

    // Text / programming languages
    .init(bundleID: "com.sublimetext.4", ext: "py"),
    .init(bundleID: "com.sublimetext.4", ext: "py3"),
    .init(bundleID: "com.sublimetext.4", ext: "cpp"),
    .init(bundleID: "com.sublimetext.4", ext: "h"),
    .init(bundleID: "com.sublimetext.4", ext: "c"),
    .init(bundleID: "com.sublimetext.4", ext: "java"),
    .init(bundleID: "com.sublimetext.4", ext: "js"),
    .init(bundleID: "com.sublimetext.4", ext: "ts"),
    .init(bundleID: "com.sublimetext.4", ext: "tsx"),
    .init(bundleID: "com.sublimetext.4", ext: "mjs"),
    .init(bundleID: "com.sublimetext.4", ext: "css"),
    .init(bundleID: "com.sublimetext.4", ext: "swift"),
    .init(bundleID: "com.sublimetext.4", ext: "php"),
    .init(bundleID: "com.sublimetext.4", ext: "sh"),
    .init(bundleID: "com.sublimetext.4", ext: "bash"),

    // Video
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "mp4"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "avi"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "mov"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "wmv"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "flv"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "webm"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "mkv"),

    // Audio
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "mp3"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "flac"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "wav"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "aac"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "ogg"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "m4a"),
    .init(bundleID: "com.Eltima.ElmediaPlayer", ext: "wma"),
]

struct PendingChange {
    let ext: String
    let bundleID: String
    let type: UTType
    let targetURL: URL
    let currentApp: String?
}

var pending: [PendingChange] = []

for d in defaults {
    guard let type = UTType(filenameExtension: d.ext) else {
        continue
    }
    guard let targetURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: d.bundleID) else {
        print("  .\(d.ext) — app \(d.bundleID) not found, skipping")
        continue
    }
    if let currentApp = NSWorkspace.shared.urlForApplication(toOpen: type),
       currentApp == targetURL {
        continue
    }

    let currentName = NSWorkspace.shared.urlForApplication(toOpen: type)?
        .deletingPathExtension().lastPathComponent
    pending.append(PendingChange(
        ext: d.ext, bundleID: d.bundleID, type: type,
        targetURL: targetURL, currentApp: currentName
    ))
}

if pending.isEmpty {
    print("Everything already up to date.")
} else {
    print("The following defaults will change:\n")
    for p in pending {
        let from = p.currentApp ?? "(none)"
        let toName = p.targetURL.deletingPathExtension().lastPathComponent
        print("  .\(p.ext): \(from) -> \(toName)")
    }
    print("\n⚠️  macOS will show a confirmation dialog for each change.")
    print("   You will need to click the button to confirm each one.\n")
    print("Apply \(pending.count) change(s)? [y/N] ", terminator: "")

    guard let answer = readLine()?.trimmingCharacters(in: .whitespaces).lowercased(),
          answer == "y" else {
        print("Cancelled.")
        exit(0)
    }

    for p in pending {
        NSWorkspace.shared.setDefaultApplication(at: p.targetURL, toOpen: p.type)
        print("  .\(p.ext) -> \(p.bundleID) (\(p.type.identifier))")
    }
    print("\nUpdated \(pending.count) handler(s).")
}

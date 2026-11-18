// CyPort test mod for RedFileSystem. Install as r6/scripts/CyPortRedFileSystemTest.reds (compiled into final.redscripts).
// Opening the main menu writes two files into r6/storages/shared/ of the game folder:
//   cyport-redfs.txt          "RedFileSystem works", "line 2", "line 3"
//   cyport-redfs-report.txt   write=true exists=True size=34 files=<n> path=<absolute path>, then the text read back
// The shared storage is used because a named storage may only be requested once per game session.
module CyPortTest.RedFileSystem
import RedFileSystem.*

@wrapMethod(SingleplayerMenuGameController)
protected cb func OnInitialize() -> Bool {
  let result = wrappedMethod();
  RunRedFileSystemTest();
  return result;
}

func RunRedFileSystemTest() -> Void {
  let storage = FileSystem.GetSharedStorage();
  if !IsDefined(storage) {
    FTLog("[CyPortTest] RedFileSystem: no shared storage (is the plugin loaded?)");
    return;
  }
  let file = storage.GetFile("cyport-redfs.txt");
  let written = file.WriteText("RedFileSystem works\n");
  let lines: array<String> = ["line 2", "line 3"];
  written = written && file.WriteLines(lines, FileSystemWriteMode.Append);
  let text = file.ReadAsText();
  let exists = storage.Exists("cyport-redfs.txt");
  let count = ArraySize(storage.GetFiles());
  let report = storage.GetFile("cyport-redfs-report.txt");
  report.WriteText(s"write=\(written) exists=\(exists) size=\(file.GetSize()) files=\(count) path=\(file.GetAbsolutePath())\n---\n\(text)\n");
  // An asynchronous read: the job thread calls back into this script object.
  let probe = new RedFileSystemTestProbe();
  probe.storage = storage;
  storage.GetAsyncFile("cyport-redfs.txt").ReadAsLines(FilePromise.Create(probe, n"OnLines", n"OnFailed"));
  GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(probe, 5.0, false);
  FTLog(s"[CyPortTest] RedFileSystem: write=\(written) exists=\(exists)");
}

// Kept alive by the delay system for five seconds (the promise only holds a weak reference).
public class RedFileSystemTestProbe extends DelayCallback {
  public let storage: ref<FileSystemStorage>;

  public func Call() -> Void {}

  public func OnLines(lines: array<String>) -> Void {
    this.storage.GetFile("cyport-redfs-async.txt").WriteText(s"async read: \(ArraySize(lines)) lines, first=\(lines[0])\n");
  }

  public func OnFailed() -> Void {
    this.storage.GetFile("cyport-redfs-async.txt").WriteText("async read: rejected\n");
  }
}

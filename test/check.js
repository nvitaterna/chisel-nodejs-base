// smoke test run with the official node binary on the base image
const fs = require("fs");
const os = require("os");
const checks = {
  user: os.userInfo().username === "node",
  home: process.cwd() === "/home/node",
  caCertificates: fs.existsSync("/etc/ssl/certs/ca-certificates.crt"),
  tzdata: fs.existsSync("/usr/share/zoneinfo/America/Toronto"),
  osRelease: fs.readFileSync("/etc/os-release", "utf8").includes("VERSION_ID="),
};
console.log(process.version, process.arch, checks);
if (Object.values(checks).includes(false)) process.exit(1);

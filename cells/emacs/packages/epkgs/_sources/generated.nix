# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  beardbolt = {
    pname = "beardbolt";
    version = "06fd5a1eeee6e8fa6ff598654863904fd67d4188";
    src = fetchgit {
      url = "https://github.com/joaotavora/beardbolt.git";
      rev = "06fd5a1eeee6e8fa6ff598654863904fd67d4188";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-K0F9fjBvHeRE5lLH9WdPPE5alrB5NpzMuwmQedw5bFI=";
    };
    date = "2022-09-10";
  };
  multi-eshell = {
    pname = "multi-eshell";
    version = "ac10d93d64e6ea9706ae4396df186faeecaaea12";
    src = fetchgit {
      url = "https://github.com/emacsmirror/multi-eshell";
      rev = "ac10d93d64e6ea9706ae4396df186faeecaaea12";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Lls1LjLStKtsDEQmHragHQ27zKOwEJgMn1VjZCTQp6Y=";
    };
    date = "2012-06-08";
  };
}
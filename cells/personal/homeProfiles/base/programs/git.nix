{inputs}: {
  enable = true;
  userName = "Nicholas Sielicki";
  userEmail = "git@opensource.nslick.com";

  package = inputs.nixpkgs.symlinkJoin {
    name = "git";
    paths = with inputs.nixpkgs; [
      gitAndTools.gitFull
      git-review
      git-lfs
      git-filter-repo
      git-subrepo
      git-autofixup
      lazygit
    ];
  };

  ignores = [
    ".vscode"
    "compile_commands.json"
    "tags"
    "TAGS"
    ".tags/"
    ".tags"
    ".cache"
    ".ccls-cache"
    ".dumbjumpignore"
    ".editorconfig"
    ".dir-locals.el"
    ".dumbjump"
    ".direnv"
    ".direnv/"
    "__pycache__"
    ".ccls-root"
  ];

  extraConfig = {
    core = {
      whitespace = "trailing-space,space-before-tab";
      fsmonitor = true;
      untrackedcache = true;
      commitgraph = true;
      sshCommand =
        if inputs.nixpkgs.stdenv.isDarwin
        then "/usr/bin/ssh"
        else "${inputs.nixpkgs.openssh}/bin/ssh";
    };
    fetch = {
      writeCommitGraph = true;
    };
    feature = {
      manyFiles = true;
      experimental = true;
    };
    merge.conflictstyle = "diff3";
    diff = {
      wsErrorHighlight = "all";
      colorMoved = "default";
      log.diffMerges = "first-parent";
    };
    format.signoff = true;
    push.default = "simple";
    pull.ff = "only";
    pull.rebase = true;
    gitreview = {
      remote = "origin";
    };
    http.emptyAuth = true;
  };
}

# dotfiles

기기 간에 공유할 설정만 선택적으로 관리하는 개인 dotfiles 저장소입니다.
현재는 [Ghostty](https://ghostty.org/) 설정만 포함합니다.

## 구조

```text
dotfiles/
└── ghostty/
    └── config.ghostty
```

## Ghostty 설정 명세

| 옵션 | 값 | 설명 |
| --- | --- | --- |
| `theme` | `Gruvbox Dark` | Ghostty에 내장된 Gruvbox 다크 테마를 사용합니다. |
| `copy-on-select` | `clipboard` | 선택한 텍스트를 macOS 시스템 클립보드에 자동 복사합니다. |
| `link-url` | `true` | `Command`를 누른 채 URL을 가리키면 링크로 인식하고 기본 앱으로 열 수 있게 합니다. |
| `shell-integration-features` | `ssh-env,ssh-terminfo` | SSH 접속 시 Ghostty의 환경과 terminfo 전달을 지원합니다. 생략한 셸 통합 기능은 Ghostty 기본값을 따릅니다. |
| `mouse-hide-while-typing` | `true` | 입력을 시작하면 마우스 포인터를 숨기고, 마우스를 움직이면 다시 표시합니다. |

Ghostty 설정 문법은 `key = value` 형식입니다. 변경 사항은 macOS에서
`Command + Shift + ,`를 눌러 다시 불러올 수 있습니다.

## 다른 Mac에 설치

### 1. 준비

Homebrew와 GitHub CLI가 없다면 설치합니다.

```sh
brew install gh
brew install --cask ghostty
gh auth login -h github.com
```

### 2. 저장소 복제

```sh
gh repo clone finalsoul1/dotfiles "$HOME/dotfiles"
```

### 3. 기존 설정 백업

Ghostty를 한 번 실행한 뒤 기존 설정 파일이 있다면 백업합니다.

```sh
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
mv "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" \
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty.local-backup"
```

기존 설정 파일이 없다면 `mv` 명령에서 `No such file or directory`가 나올 수 있으며,
이 경우 다음 단계로 진행하면 됩니다.

### 4. 설정 연결

```sh
ln -s "$HOME/dotfiles/ghostty/config.ghostty" \
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
```

연결 상태는 다음 명령으로 확인합니다.

```sh
ls -l "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
```

## 설정 변경과 동기화

설정을 변경해 GitHub에 올립니다.

```sh
cd "$HOME/dotfiles"
git add ghostty/config.ghostty
git commit -m "Update Ghostty config"
git push
```

다른 Mac에서 최신 설정을 받습니다.

```sh
cd "$HOME/dotfiles"
git pull
```

symlink가 저장소 파일을 직접 가리키므로 복사 작업은 다시 할 필요가 없습니다.

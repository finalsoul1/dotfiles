# dotfiles

기기 간에 공유할 설정만 선택적으로 관리하는 개인 dotfiles 저장소입니다.
현재는 [Ghostty](https://ghostty.org/)와 Zsh 디렉터리 탐색 설정을 포함합니다.

## 구조

```text
dotfiles/
├── ghostty/
│   └── config.ghostty
└── zsh/
    ├── clipboard.zsh
    ├── media.zsh
    └── navigation.zsh
```

## Slack에 표 붙여넣기

`zsh/clipboard.zsh`의 `tbl2clip`은 마크다운 표나 TSV를 받아 클립보드에 올립니다.
Slack 입력창에 그대로 붙여넣으면 표로 들어갑니다.

```sh
tbl2clip routes.md          # 파일에서
cat routes.md | tbl2clip    # 파이프로
```

HTML과 plain text 두 flavor를 함께 싣습니다. HTML만 넣으면 plain text가 비어
대부분의 앱이 붙여넣기를 무시하기 때문입니다. 실행 후 `pbpaste`로 자체 검증합니다.
`` `코드` ``와 `**굵게**`만 서식으로 변환하고 나머지는 그대로 둡니다.

## 영상을 GIF로 바꾸기

`zsh/media.zsh`의 `vid2gif`는 화면 기록 영상을 크기가 작은 GIF로 바꿉니다.

```sh
vid2gif 화면기록.mov 300 10   # 영상 → GIF (width=400, fps=12 기본값)
```

`ffmpeg`가 필요합니다(`brew install ffmpeg`).

## Zsh 디렉터리 탐색

`zsh/navigation.zsh`는 `zoxide`와 `fzf`를 사용해 다음 기능을 제공합니다.

- `cd`를 zoxide 기반 디렉터리 이동 명령으로 확장
- 기존 `z`와 `zi` 호환 명령 유지
- 디렉터리 이름 중간 문자열 Tab 완성
- `$HOME/Desktop/Projects` 아래 실제 디렉터리를 방문 전에도 Tab 완성
- `cdi`와 `zi`를 통한 대화형 검색

필요한 패키지를 설치합니다.

```sh
brew install fzf zoxide
```

`$HOME/.zshrc`에서 공유 설정을 불러옵니다. `.zshrc`는 이 저장소에 포함되지 않으므로
새 기기에서는 아래 세 줄을 직접 추가합니다.

```sh
source "$HOME/dotfiles/zsh/navigation.zsh"
source "$HOME/dotfiles/zsh/media.zsh"
source "$HOME/dotfiles/zsh/clipboard.zsh"
```

기본 프로젝트 경로가 다른 기기에서는 `source`보다 먼저 경로를 지정합니다.

```sh
export ZOXIDE_PROJECT_COMPLETION_ROOT="$HOME/Developer"
source "$HOME/dotfiles/zsh/navigation.zsh"
```

주요 사용 예시는 다음과 같습니다.

```sh
cd 748<Tab>  # Projects 아래 실제 디렉터리 완성
z 748<Tab>   # cd와 동일한 호환 명령
cdi front    # zoxide 방문 기록에서 대화형 선택
builtin cd   # 원래 Zsh 내장 cd 사용
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

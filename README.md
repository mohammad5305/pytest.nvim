# Pytest.nvim

## Description
`pytest.nvim`  is an plugin for running tests asynchronously and making test snippet based on treesitter

## Installation

[vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'mohammad5305/pytest.nvim'

lua << EOF
require("pytest").setup()
EOF
```

[packer](https://github.com/wbthomason/packer.nvim)

```
use {
    'mohammad5305/pytest.nvim',
    config = function () require('pytest').setup() end
}
```

## Usage

For making snippet use `:PytestMkSnip` also for disabling the prompt when tests directory does
not exist set `snippet.dir_not_exists_prompt` option to false and for running tests `:PytestRun`

**_NOTE:_**: parametrized test cases are not supported yet because there is no such good way to show more than one result in sign column

## Contributing
Read [CONTRIBUTING.md](CONTRIBUTING.md)


## TODO
[TODO list](https://github.com/mohammad5305/pytest.nvim/issues/1)

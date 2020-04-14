# PowerB

Running locally

brew tap microsoft/mssql-preview https://github.com/Microsoft/homebrew-mssql-preview
brew install –no-sandbox msodbcsql mssql-tools

Now you can connect to your SQL Server with sqlcmd command line utility from Mac OS Terminal.

sqlcmd -S localhost,1401 -U sa -P password

pip install mssql-cli
pip install sqlcmd


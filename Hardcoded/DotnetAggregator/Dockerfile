FROM mcr.microsoft.com/dotnet/sdk:9.0
WORKDIR /app
COPY ["DotnetAggregator.csproj", "."]
RUN dotnet restore "DotnetAggregator.csproj"
COPY . .
RUN dotnet publish "./DotnetAggregator.csproj" -c Release -o /publish /p:UseAppHost=false
EXPOSE 8080
EXPOSE 8081
ENTRYPOINT ["dotnet", "/publish/DotnetAggregator.dll"]

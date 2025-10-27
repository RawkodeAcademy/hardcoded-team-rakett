FROM mcr.microsoft.com/dotnet/sdk:9.0
WORKDIR /app
COPY ["Normalizer.csproj", "."]
RUN dotnet restore "Normalizer.csproj"
COPY . .
RUN dotnet publish "./Normalizer.csproj" -c Release -o /publish /p:UseAppHost=false
EXPOSE 8080
EXPOSE 8081
ENTRYPOINT ["dotnet", "/publish/Normalizer.dll"]

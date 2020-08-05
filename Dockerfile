FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["BettyBeer/BettyBeer.csproj", "BettyBeer/"]
RUN dotnet restore "BettyBeer/BettyBeer.csproj"
COPY ./MyApi ./MyApi
WORKDIR "/src/BettyBeer"
RUN dotnet build "BettyBeer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BettyBeer.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY ./CounterPage/build ./wwwroot

RUN useradd -m myappuser
USER myappuser

CMD ASPNETCORE_URLS="http://*:$PORT" dotnet MyApi.dll
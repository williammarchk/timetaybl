// Compile command: CGO_ENABLED=0 gomobile bind -target macos -o ../frameworks/GoogleApi.xcframework

package googleapi

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/calendar/v3"
	"google.golang.org/api/option"
)

type GoogleDataLoader struct {
	hasError bool
	client   *http.Client
	service  *calendar.Service
	config   *oauth2.Config
}

func NewDataLoader(credentials string) *GoogleDataLoader {
	var config, err = google.ConfigFromJSON([]byte(credentials), calendar.CalendarReadonlyScope)

	if err != nil {
		fmt.Println("Error in generating config")
	}

	return &GoogleDataLoader{false, &http.Client{}, &calendar.Service{}, config}
}

func (loader *GoogleDataLoader) GetAuthURLstring() string {
	return loader.config.AuthCodeURL("state-token", oauth2.AccessTypeOffline)
}

func (loader *GoogleDataLoader) GetClient(authCode string) {
	var token, err = loader.config.Exchange(context.TODO(), authCode)

	if err != nil {
		loader.hasError = true

		fmt.Println("Error in exchanging token")
	}

	loader.client = loader.config.Client(context.Background(), token)
	service, err := calendar.NewService(context.Background(), option.WithHTTPClient(loader.client))

	if err != nil {
		loader.hasError = true

		fmt.Println("Error getting Calendar API service")
	}

	loader.service = service
}

func (loader *GoogleDataLoader) GetEvents() string {
	events, err := loader.service.Events.List("primary").SingleEvents(true).TimeMin("2022-09-12T00:00:00Z").TimeMax("2022-09-24T22:00:00Z").OrderBy("startTime").Do()

	if err != nil {
		loader.hasError = true
	}

	startOfCycle, _ := time.Parse(time.RFC3339, "2022-09-12T00:00:00+02:00")

	items := events.Items

	result := make([]*Lesson, 0)

	for _, s := range items {
		new_item := Lesson{}

		startTime, _ := time.Parse(time.RFC3339, s.Start.DateTime)
		endTime, _ := time.Parse(time.RFC3339, s.End.DateTime)

		dayOfCycle := startTime.Local().Day() - startOfCycle.Local().Day()

		new_item.SubjectName = s.Summary
		new_item.Location = s.Location

		if dayOfCycle < 6 {
			new_item.Day = dayOfCycle
			new_item.Week = 1
		} else {
			new_item.Day = dayOfCycle - 7
			new_item.Week = 2
		}

		new_item.StartHour = startTime.Local().Hour()
		new_item.StartMinute = startTime.Local().Minute()

		new_item.EndHour = endTime.Local().Hour()
		new_item.EndMinute = endTime.Local().Minute()

		// Check if generated from ISAMS and not lunch
		if strings.Contains(s.Description, "Generated from isams") {
			result = append(result, &new_item)
		}
	}

	json, err := json.Marshal(result)

	if err != nil {
		loader.hasError = true
	}

	return string(json)
}

type Lesson struct {
	SubjectName string
	Location    string
	Week        int
	Day         int
	StartHour   int
	EndHour     int
	StartMinute int
	EndMinute   int
}

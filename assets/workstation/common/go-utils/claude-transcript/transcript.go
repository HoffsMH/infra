package transcript

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"strings"
)

type entry struct {
	UUID        string  `json:"uuid"`
	ParentUUID  string  `json:"parentUuid"`
	Type        string  `json:"type"`
	IsSidechain bool    `json:"isSidechain"`
	IsMeta      bool    `json:"isMeta"`
	Message     message `json:"message"`
}

type message struct {
	Role    string          `json:"role"`
	Content json.RawMessage `json:"content"`
}

type contentBlock struct {
	Type string `json:"type"`
	Text string `json:"text"`
}

func Write(input io.Reader, output io.Writer) error {
	entries, err := readEntries(input)
	if err != nil {
		return err
	}

	byID := make(map[string]entry, len(entries))
	var leaf entry
	for _, item := range entries {
		if item.UUID != "" {
			byID[item.UUID] = item
		}
		if item.UUID != "" && isMessage(item.Type) && !item.IsSidechain {
			leaf = item
		}
	}

	chain := make([]entry, 0)
	seen := make(map[string]bool)
	for leaf.UUID != "" && !seen[leaf.UUID] {
		seen[leaf.UUID] = true
		chain = append(chain, leaf)
		leaf = byID[leaf.ParentUUID]
	}

	for i := len(chain) - 1; i >= 0; i-- {
		item := chain[i]
		if item.IsMeta {
			continue
		}

		text := messageText(item.Message.Content)
		if text == "" {
			continue
		}

		role := item.Message.Role
		if role == "" {
			role = item.Type
		}
		if _, err := fmt.Fprintf(output, "%s\n\n%s\n\n", strings.ToUpper(role), text); err != nil {
			return err
		}
	}

	return nil
}

func readEntries(input io.Reader) ([]entry, error) {
	reader := bufio.NewReader(input)
	var entries []entry

	for {
		line, err := reader.ReadBytes('\n')
		if len(bytes.TrimSpace(line)) > 0 {
			var item entry
			if json.Unmarshal(line, &item) == nil {
				entries = append(entries, item)
			}
		}
		if err != nil {
			if err == io.EOF {
				return entries, nil
			}
			return nil, err
		}
	}
}

func isMessage(kind string) bool {
	return kind == "user" || kind == "assistant"
}

func messageText(content json.RawMessage) string {
	var plain string
	if json.Unmarshal(content, &plain) == nil {
		return strings.TrimSpace(plain)
	}

	var blocks []contentBlock
	if json.Unmarshal(content, &blocks) != nil {
		return ""
	}

	texts := make([]string, 0, len(blocks))
	for _, block := range blocks {
		if block.Type == "text" && block.Text != "" {
			texts = append(texts, block.Text)
		}
	}
	return strings.TrimSpace(strings.Join(texts, "\n"))
}
